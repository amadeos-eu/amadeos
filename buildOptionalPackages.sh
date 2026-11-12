#!/usr/bin/env bash
# Builds the optional packages of amadeOS: the programs marked "# optional" in repositories.list (for now the
# games other than Mines and Solitaire), which the image leaves out. Like buildDistribution.sh it
#
#   0. clones the optional repositories that are not checked out next to amadeos yet
#   1. pulls that branch of them and of the libraries (amade-commons, amade-game-engine)
#   2. builds every one against those checkouts (composite build), with its tests, as a Debian package
#   3. collects the packages in artifacts/optional/, with the meta package amadeos-games and a Packages index
#
# Nothing goes into config/packages.chroot/, so the next image stays without them. To try them on an amadeOS
# system (or in QEMU through ~/qemu-share): sudo apt install ./artifacts/optional/*.deb
#
# Usage: ./buildOptionalPackages.sh [--branch develop|release|main] [--no-clone] [--no-pull] [--skip-tests]
#                                   [--apps "amade-snake-game amade-town-game"] [--out DIR]
#
#   --branch B    build branch B: develop (default), release or main; a repository without it is built from main
#   --no-clone    do not clone missing repositories; build only what is checked out
#   --no-pull     build the checkouts as they are (no git fetch, no branch switch)
#   --skip-tests  skip the unit tests (they run under xvfb-run otherwise)
#   --apps LIST   build only these optional repositories (directory names, space-separated)
#   --out DIR     put the packages there instead of artifacts/optional/
set -euo pipefail

# Everything runs inside main(), as in buildDistribution.sh: pulling a newer amadeos cannot change the script
# halfway through.
main() {
    local root_dir parent_dir branch="develop"
    root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    parent_dir="$(dirname "$root_dir")"

    local clone=1 pull=1 tests=1 apps_arg="" out_dir="$root_dir/artifacts/optional"
    while [ $# -gt 0 ]; do
        case "$1" in
            --branch) shift; branch="${1:?--branch needs develop, release or main}" ;;
            --no-clone) clone=0 ;;
            --no-pull) pull=0 ;;
            --skip-tests) tests=0 ;;
            --apps) shift; apps_arg="${1:?--apps needs a list of repositories}" ;;
            --out) shift; out_dir="${1:?--out needs a directory}" ;;
            -h|--help) sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; return 0 ;;
            *) echo "Unknown option: $1 (see --help)" >&2; return 1 ;;
        esac
        shift
    done

    local optional=() repo
    mapfile -t optional < <("$root_dir/scripts/list-repositories.sh" --optional)
    local apps=()
    if [ -n "$apps_arg" ]; then
        for repo in $apps_arg; do
            [[ " ${optional[*]} " == *" $repo "* ]] || {
                echo "$repo is not marked optional in repositories.list (see scripts/list-repositories.sh --optional)" >&2
                return 1; }
            apps+=("$repo")
        done
    else
        apps=("${optional[@]}")
    fi
    [ ${#apps[@]} -gt 0 ] || { echo "repositories.list has no optional repositories" >&2; return 1; }

    if [ "$clone" = 1 ]; then
        for repo in "${apps[@]}"; do
            [ -d "$parent_dir/$repo" ] && continue
            step "Cloning $repo"
            git clone "https://github.com/amadeos-eu/$repo.git" "$parent_dir/$repo"
        done
    fi
    for repo in "${apps[@]}"; do
        [ -d "$parent_dir/$repo" ] || { echo "$repo is not checked out next to amadeos (leave out --no-clone)" >&2; return 1; }
    done

    local libraries=(amade-commons)
    [ -f "$parent_dir/amade-game-engine/settings.gradle" ] && libraries+=(amade-game-engine)
    [ -f "$parent_dir/amade-commons/settings.gradle" ] || {
        echo "amade-commons not found at $parent_dir/amade-commons; clone it next to amadeos" >&2; return 1; }

    # The version script (next-version.sh) comes from amadeos-ci, next to amadeos.
    local ci_dir="$parent_dir/amadeos-ci"
    if [ ! -d "$ci_dir" ]; then
        step "Cloning amadeos-ci"
        git clone "https://github.com/amadeos-eu/amadeos-ci.git" "$ci_dir"
    elif [ "$pull" = 1 ]; then
        git -C "$ci_dir" pull --ff-only --quiet origin main
    fi

    if [ "$pull" = 1 ]; then
        local dirty=0
        for repo in "${libraries[@]}" "${apps[@]}"; do
            if [ -n "$(git -C "$parent_dir/$repo" status --porcelain --untracked-files=no)" ]; then
                echo "$repo has uncommitted changes; commit or stash them, or use --no-pull" >&2
                dirty=1
            fi
        done
        [ "$dirty" = 0 ] || return 1
        local repo_branch
        for repo in "${libraries[@]}" "${apps[@]}"; do
            repo_branch="$branch"
            git -C "$parent_dir/$repo" ls-remote --exit-code --heads origin "$branch" >/dev/null || repo_branch=main
            step "Pulling $repo ($repo_branch)"
            git -C "$parent_dir/$repo" fetch --tags origin "$repo_branch"
            if [ "$(git -C "$parent_dir/$repo" branch --show-current)" != "$repo_branch" ]; then
                git -C "$parent_dir/$repo" switch "$repo_branch"
            fi
            git -C "$parent_dir/$repo" merge --ff-only "origin/$repo_branch"
        done
    fi

    local gradle_args=(--no-daemon clean)
    if [ "$tests" = 1 ]; then gradle_args+=(build); else gradle_args+=(assemble); fi
    local display_wrapper=()
    if [ "$tests" = 1 ]; then
        command -v xvfb-run >/dev/null || {
            echo "The tests need xvfb-run: sudo apt install xvfb (or build with --skip-tests)" >&2; return 1; }
        display_wrapper=(xvfb-run -a -s "-screen 0 1440x900x24")
    fi

    mkdir -p "$out_dir"
    local version channel deb
    for repo in "${apps[@]}"; do
        step "Building $repo"
        # The same versions as buildDistribution.sh: X.Y.Z-dev.0 on develop, X.Y.Z-pre.0 on release, exactly
        # X.Y.Z on a tagged main; all lower than the CI builds of that version on apt.amadeos.eu.
        channel=dev
        case "$(git -C "$parent_dir/$repo" branch --show-current)" in
            release) channel=pre ;;
            main) git -C "$parent_dir/$repo" tag --points-at HEAD | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$' && channel=release ;;
        esac
        version=$(cd "$parent_dir/$repo" && GITHUB_RUN_NUMBER=0 "$ci_dir/scripts/next-version.sh" "$channel")
        (cd "$parent_dir/$repo" && "${display_wrapper[@]}" ./gradlew "${gradle_args[@]}" -PappVersion="$version" deb)
        rm -f "$out_dir/${repo}"_*.deb
        for deb in "$parent_dir/$repo"/build/distributions/*.deb; do
            [ -f "$deb" ] && cp "$deb" "$out_dir/"
        done
    done

    # amadeos-games (scripts/package-desktop-meta.sh builds it next to amadeos-desktop, which is not wanted here).
    step "Building the meta package amadeos-games"
    local meta_dir meta_channel=dev
    meta_dir="$(mktemp -d)"
    # The version of the amadeos checkout, as for the image (scripts/build-image.sh).
    case "$(git -C "$root_dir" branch --show-current)" in
        release) meta_channel=pre ;;
        main) git -C "$root_dir" tag --points-at HEAD | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$' && meta_channel=release ;;
    esac
    version="${AMADEOS_VERSION:-$(cd "$root_dir" && GITHUB_RUN_NUMBER=0 "$ci_dir/scripts/next-version.sh" "$meta_channel")}"
    "$root_dir/scripts/package-desktop-meta.sh" --version "$version" "$meta_dir" >/dev/null
    rm -f "$out_dir"/amadeos-games_*.deb
    cp "$meta_dir"/amadeos-games_*.deb "$out_dir/"
    rm -rf "$meta_dir"

    # A Packages index, so the folder also works as a local apt source: deb [trusted=yes] file:/path/to/optional ./
    if command -v dpkg-scanpackages >/dev/null; then
        (cd "$out_dir" && dpkg-scanpackages --multiversion . /dev/null 2>/dev/null | gzip -9n > Packages.gz)
    fi

    step "Done"
    BUILD_DONE=1
    echo "Packages in $out_dir:"
    (cd "$out_dir" && ls -1 -- *.deb | sed 's/^/  /')
    echo
    echo "Install on amadeOS:  sudo apt install $out_dir/*.deb"
}

# Step timings, as in buildDistribution.sh.
BUILD_STARTED=$SECONDS BUILD_DONE=0 CURRENT_STEP="" STEP_STARTED=$SECONDS
STEP_NAMES=() STEP_TIMES=()

step() {
    finish_step
    CURRENT_STEP="$*" STEP_STARTED=$SECONDS
    printf '\n\033[1m[buildOptionalPackages] %s\033[0m\n' "$*"
}

finish_step() {
    [ -n "$CURRENT_STEP" ] || return 0
    STEP_NAMES+=("$CURRENT_STEP") STEP_TIMES+=("$((SECONDS - STEP_STARTED))")
    CURRENT_STEP=""
}

duration() {
    local s=$1
    if [ "$s" -ge 3600 ]; then printf '%dh %02dm %02ds' $((s / 3600)) $((s % 3600 / 60)) $((s % 60))
    elif [ "$s" -ge 60 ]; then printf '%dm %02ds' $((s / 60)) $((s % 60))
    else printf '%ds' "$s"; fi
}

report_durations() {
    local status=$? failed_step="$CURRENT_STEP" i short=0 total=$((SECONDS - BUILD_STARTED))
    finish_step
    [ ${#STEP_NAMES[@]} -gt 0 ] || return "$status"
    printf '\n\033[1m[buildOptionalPackages] Durations\033[0m\n'
    for i in "${!STEP_NAMES[@]}"; do
        [ "${STEP_NAMES[$i]}" = "Done" ] && continue
        if [ "${STEP_TIMES[$i]}" -ge 10 ]; then
            printf '  %12s  %s\n' "$(duration "${STEP_TIMES[$i]}")" "${STEP_NAMES[$i]}"
        else
            short=$((short + STEP_TIMES[$i]))
        fi
    done
    [ "$short" -eq 0 ] || printf '  %12s  %s\n' "$(duration "$short")" "shorter steps (under 10s each)"
    if [ "$BUILD_DONE" = 1 ]; then
        printf '\033[1mBuild time: %s\033[0m\n' "$(duration "$total")"
    else
        printf '\033[1mBuild failed after %s in step: %s\033[0m\n' "$(duration "$total")" "${failed_step:-setup}"
    fi
    return "$status"
}
trap report_durations EXIT

main "$@"
exit
