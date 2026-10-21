#!/usr/bin/env bash
# Builds the complete amadeOS distribution from the main branches of all repositories:
#
#   0. clones the repositories of repositories.list that are not checked out next to amadeos yet
#   1. pulls main of amadeos, the libraries (amade-commons, amade-game-engine) and every amade app
#   2. builds amade-commons, then every app against that checkout (composite build)
#   3. drops every app's .deb into config/packages.chroot/ (gradlew installToAmadeOs), and the handbooks
#   4. builds artifacts/amadeos-amd64.iso (./build.sh, uses sudo for live-build)
#
# Expected layout (an app is every ../amade-*/ or ../amadeos-*/ whose build.gradle has an installToAmadeOs task):
#
#   <parent>/amadeos  <parent>/amade-commons  <parent>/amade-pad  <parent>/amade-mail  ...
#
# Usage: ./buildDistribution.sh [--no-clone] [--no-pull] [--skip-tests] [--quick] [--apps "amade-pad amade-mail"]
#
#   --no-clone    do not clone missing repositories; build only what is checked out
#   --no-pull     build the checkouts as they are (no git fetch, no branch switch)
#   --skip-tests  skip the unit tests of amade-commons and the apps
#   --quick       repack the previous image instead of a full live-build (AMADEOS_QUICK=1)
#   --apps LIST   build only these apps (directory names, space-separated)
#
# Writing the ISO to a USB stick is described in README.md ("Writing the image to a USB stick").
set -euo pipefail

# Everything runs inside main(): bash reads the whole function before executing it, so pulling a
# newer version of this script into the amadeos checkout cannot change the build halfway through.
main() {
    local root_dir parent_dir branch="main"
    root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    parent_dir="$(dirname "$root_dir")"

    local clone=1 pull=1 tests=1 quick=0 apps_arg=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --no-clone) clone=0 ;;
            --no-pull) pull=0 ;;
            --skip-tests) tests=0 ;;
            --quick) quick=1 ;;
            --apps) shift; apps_arg="${1:?--apps needs a list of app directories}" ;;
            -h|--help) sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; return 0 ;;
            *) echo "Unknown option: $1 (see --help)" >&2; return 1 ;;
        esac
        shift
    done

    # live-build needs root; ask for the password now instead of after the Java builds.
    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 || { echo "sudo is required for live-build" >&2; return 1; }
        sudo -v
    fi

    # With --apps only the named checkouts are built, so nothing is cloned.
    if [ "$clone" = 1 ] && [ -z "$apps_arg" ]; then
        local name
        while read -r name; do
            [ -d "$parent_dir/$name" ] && continue
            step "Cloning $name"
            git clone "https://github.com/datazuul/$name.git" "$parent_dir/$name"
        done < <(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$root_dir/repositories.list")
    fi

    local commons_dir="$parent_dir/amade-commons"
    [ -f "$commons_dir/settings.gradle" ] || {
        echo "amade-commons not found at $commons_dir; clone it next to amadeos" >&2; return 1; }

    local apps=() app
    if [ -n "$apps_arg" ]; then
        for app in $apps_arg; do
            grep -qs "installToAmadeOs" "$parent_dir/$app/build.gradle" || {
                echo "$parent_dir/$app is no amade app (no installToAmadeOs task in build.gradle)" >&2; return 1; }
            apps+=("$app")
        done
    else
        local dir
        # ../amade-* are the applications and amadeos-system, ../amadeos-* the installer (amadeos itself has no hyphen).
        for dir in "$parent_dir"/amade-*/ "$parent_dir"/amadeos-*/; do
            [ -d "$dir" ] || continue
            app="$(basename "$dir")"
            [ "$app" = "amade-commons" ] && continue
            grep -qs "installToAmadeOs" "$dir/build.gradle" && apps+=("$app")
        done
    fi
    [ ${#apps[@]} -gt 0 ] || { echo "No amade apps found in $parent_dir" >&2; return 1; }

    # The libraries are pulled like the apps; the apps' composite builds compile them. amade-game-engine
    # is also an app when it has an installToAmadeOs task (the package of its handbook).
    local libraries=(amade-commons)
    if [ -f "$parent_dir/amade-game-engine/settings.gradle" ] && [[ " ${apps[*]} " != *" amade-game-engine "* ]]; then
        libraries+=(amade-game-engine)
    fi

    step "Repositories: amadeos ${libraries[*]} ${apps[*]}"

    if [ "$pull" = 1 ]; then
        # Check every repository before touching any, so a dirty checkout does not leave half of
        # them pulled.
        local repo dirty=0
        for repo in amadeos "${libraries[@]}" "${apps[@]}"; do
            if [ -n "$(git -C "$parent_dir/$repo" status --porcelain --untracked-files=no)" ]; then
                echo "$repo has uncommitted changes; commit or stash them, or use --no-pull" >&2
                dirty=1
            fi
        done
        [ "$dirty" = 0 ] || return 1
        for repo in amadeos "${libraries[@]}" "${apps[@]}"; do
            step "Pulling $repo ($branch)"
            git -C "$parent_dir/$repo" fetch origin "$branch"
            if [ "$(git -C "$parent_dir/$repo" branch --show-current)" != "$branch" ]; then
                echo "  switching $repo from $(git -C "$parent_dir/$repo" branch --show-current || true) to $branch"
                git -C "$parent_dir/$repo" switch "$branch"
            fi
            git -C "$parent_dir/$repo" merge --ff-only "origin/$branch"
        done
    fi

    local gradle_args=(--no-daemon clean)
    if [ "$tests" = 1 ]; then gradle_args+=(build); else gradle_args+=(assemble); fi

    step "Building amade-commons"
    (cd "$commons_dir" && ./gradlew "${gradle_args[@]}")

    # Remove the app packages of earlier builds, so an app whose version changed is not installed
    # twice. The icon theme and backdrop packages stay; build.sh only builds them when missing.
    local packages_dir="$root_dir/config/packages.chroot"
    mkdir -p "$packages_dir"
    local module
    for app in "${apps[@]}"; do
        rm -f "$packages_dir/${app}"_*.deb
        # A multi-project build (amadeos-system) makes one amadeos-<module> package per included module.
        for module in $(sed -n "s/^include '\([a-z0-9-]*\)'.*/\1/p" "$parent_dir/$app/settings.gradle" 2>/dev/null); do
            rm -f "$packages_dir/amadeos-${module}"_*.deb
            rm -f "$packages_dir/amade-${module}"_*.deb  # name before the rename to amadeos-*
        done
    done

    for app in "${apps[@]}"; do
        step "Building $app and adding it to amadeOS"
        # settings.gradle of every app includes ../amade-commons, so the app is built against the
        # checkout pulled above, not against the JitPack version in its build.gradle.
        (cd "$parent_dir/$app" && ./gradlew "${gradle_args[@]}" installToAmadeOs)
    done

    # amade-commons carries the Application Developer's Handbook (docs/handbook), which shows code from
    # the apps checked out above; its installToAmadeOs task packages it as amade-app-handbook. A missing
    # handbook does not stop the image: the Help drawer just lacks it.
    if grep -qs "installToAmadeOs" "$commons_dir/build.gradle"; then
        step "Building the Application Developer's Handbook (amade-app-handbook)"
        rm -f "$packages_dir"/amade-app-handbook_*.deb
        (cd "$commons_dir" && ./gradlew --no-daemon installToAmadeOs) \
            || echo "[buildDistribution] Warning: amade-app-handbook could not be built; continuing without it." >&2
    fi

    # As the user, not as root inside build.sh: MkDocs goes into docs/handbook/.venv.
    step "Building the User's Handbook (amadeos-handbook)"
    "$root_dir/scripts/package-handbook.sh" --install-iso

    step "Building the amadeOS ISO"
    if [ "$quick" = 1 ]; then
        AMADEOS_QUICK=1 "$root_dir/build.sh"
    else
        "$root_dir/build.sh"
    fi

    local iso="$root_dir/artifacts/amadeos-amd64.iso"
    step "Done"
    echo "Image:    $iso ($(du -h "$iso" | cut -f1))"
    echo "Packages: $(cd "$packages_dir" && ls -- *.deb | tr '\n' ' ')"
    cat <<EOF

Test it:      ./run-qemu.sh
USB stick:    lsblk -d -o NAME,SIZE,MODEL,TRAN      # find the stick, e.g. /dev/sdX
              sudo dd if=$iso of=/dev/sdX bs=4M status=progress conv=fsync oflag=direct
              (this erases the whole stick; see README.md, "Writing the image to a USB stick")
EOF
}

step() {
    printf '\n\033[1m[buildDistribution] %s\033[0m\n' "$*"
}

main "$@"
exit
