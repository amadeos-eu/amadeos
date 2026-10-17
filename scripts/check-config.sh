#!/usr/bin/env bash
# Checks on the live-build configuration that are easy to break by hand. Run by CI and at the start of
# scripts/build-image.sh; exits non-zero with one line per problem.
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

problems=0
fail() {
    echo "[check-config] $*" >&2
    problems=$((problems + 1))
}

# The hooks exist once, in config/hooks/normal, where current Debian live-build runs them. live-build 3.x
# on Ubuntu hosts runs config/hooks/*.chroot instead, so the build script links the hooks there in its
# copy of the configuration; the repository keeps no second copy.
normal_hooks=(config/hooks/normal/*.chroot)
[ -e "${normal_hooks[0]}" ] || fail "expected hooks in config/hooks/normal"
for hook in config/hooks/*.chroot; do
    [ -e "$hook" ] && fail "$hook: hooks belong in config/hooks/normal only"
done
for hook in "${normal_hooks[@]}"; do
    [ -x "$hook" ] || fail "$hook must be executable (git update-index --chmod=+x)"
done
grep -qF 'ln -s "normal/$(basename "$hook")" "$BUILD_ROOT/config/hooks/' scripts/build-image.sh \
    || fail "scripts/build-image.sh must link config/hooks/normal/*.chroot into config/hooks for live-build 3.0"

# The package list is the only list of packages; the hook must not install a second copy.
grep -q "apt-get install" config/hooks/normal/020-amadeos-packages.chroot \
    && fail "packages belong in config/package-lists/amadeos.list.chroot, not in the packages hook"
[ -f config/package-lists/amadeos.list.chroot ] || fail "config/package-lists/amadeos.list.chroot is missing"

# live-config takes the kernel command line before /etc/live/config.conf, so the settings of the live
# image live in config.conf alone and the command line only starts live-config.
bootappend="$(sed -n 's/^BOOTAPPEND="\([^"]*\)"$/\1/p' scripts/build-image.sh)"
[ "$bootappend" = "boot=live components" ] \
    || fail "BOOTAPPEND in scripts/build-image.sh must be exactly \"boot=live components\", is \"$bootappend\""
live_config=config/includes.chroot/etc/live/config.conf
for variable in LIVE_HOSTNAME LIVE_USERNAME LIVE_USER_DEFAULT_GROUPS LIVE_KEYBOARD_LAYOUTS LIVE_TIMEZONE; do
    grep -Eq "^$variable=\"[^\"]+\"$" "$live_config" || fail "$variable must be set in $live_config"
done
grep -q lpadmin "$live_config" && grep -q systemd-journal "$live_config" \
    || fail "the live user needs lpadmin (printing) and systemd-journal (log viewer) in $live_config"

# The desktop is the package amade-desktop; nothing may still expect the jar of the old amadeos build.
grep -rn --exclude=check-config.sh "/opt/amadeos/amadeos.jar" config scripts \
    && fail "the desktop jar is /opt/amade-desktop/amade-desktop.jar (package amade-desktop)"

# Scripts installed into the image, and their syntax.
for script in config/includes.chroot/usr/local/bin/* config/includes.chroot/etc/amadeos/autostart.d/*; do
    case "$script" in *README) continue ;; esac
    [ -x "$script" ] || fail "$script must be executable (git update-index --chmod=+x)"
    sh -n "$script" || fail "$script does not parse"
done
for script in build.sh buildDistribution.sh run-qemu.sh scripts/*.sh; do
    [ -x "$script" ] || fail "$script must be executable (git update-index --chmod=+x)"
    bash -n "$script" || fail "$script does not parse"
done
for hook in "${normal_hooks[@]}"; do
    sh -n "$hook" || fail "$hook does not parse"
done

if [ "$problems" -gt 0 ]; then
    echo "[check-config] $problems problem(s)" >&2
    exit 1
fi
echo "[check-config] configuration ok"
