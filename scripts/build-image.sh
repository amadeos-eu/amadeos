#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/config"
ARTIFACT_DIR="$ROOT_DIR/artifacts"
JAR_PATH="$CONFIG_DIR/includes.chroot/opt/dazeos/dazeos-demo.jar"
ISO_PATH="$ARTIFACT_DIR/dazeos-amd64.iso"
BUILD_ROOT="${DAZEOS_BUILD_ROOT:-${TMPDIR:-/tmp}/dazeos-live-build}"

cd "$ROOT_DIR"

command -v gradle >/dev/null 2>&1 || { echo "gradle is required" >&2; exit 1; }
command -v lb >/dev/null 2>&1 || { echo "live-build (lb) is required" >&2; exit 1; }

mkdir -p "$ARTIFACT_DIR" "$(dirname "$JAR_PATH")"
gradle clean jar
cp build/libs/dazeos-*.jar "$JAR_PATH"

# Keep the Git checkout on /mnt/c, but run live-build on a native WSL2
# filesystem. SquashFS, tar, mounts, and Unix permissions are unreliable on
# Windows-mounted paths even when DrvFs metadata is enabled.
for mount_point in \
    "$BUILD_ROOT/chroot/dev/pts" \
    "$BUILD_ROOT/chroot/dev" \
    "$BUILD_ROOT/chroot/proc" \
    "$BUILD_ROOT/chroot/sys"; do
    umount -R -lf "$mount_point" 2>/dev/null || true
done
rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"
cp -a "$CONFIG_DIR" "$BUILD_ROOT/config"
cp -a "$JAR_PATH" "$BUILD_ROOT/config/includes.chroot/opt/dazeos/dazeos-demo.jar"

cd "$BUILD_ROOT"
rm -rf chroot binary cache

# WSL2 does not allow opening device nodes created below /tmp. Bind the
# working distribution's /dev so package post-install scripts can use
# /dev/null while live-build is configuring the chroot.
mkdir -p "$BUILD_ROOT/chroot/dev"
if [ "$(id -u)" -eq 0 ]; then
    mount --bind /dev "$BUILD_ROOT/chroot/dev"
else
    sudo mount --bind /dev "$BUILD_ROOT/chroot/dev"
fi

cleanup_dev_mount() {
    if [ "$(id -u)" -eq 0 ]; then
        umount -R -lf "$BUILD_ROOT/chroot/dev" 2>/dev/null || true
    else
        sudo umount -R -lf "$BUILD_ROOT/chroot/dev" 2>/dev/null || true
    fi
}
trap cleanup_dev_mount EXIT

if [ "$(id -u)" -eq 0 ]; then
    LB=(lb)
else
    command -v sudo >/dev/null 2>&1 || { echo "sudo is required for live-build" >&2; exit 1; }
    LB=(sudo lb)
fi

"${LB[@]}" config \
    --distribution trixie \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components username=dazeos hostname=dazeos" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --parent-mirror-bootstrap https://deb.debian.org/debian \
    --parent-mirror-chroot https://deb.debian.org/debian \
    --parent-mirror-binary https://deb.debian.org/debian \
    --apt-recommends false \
    --firmware-chroot false \
    --firmware-binary false \
    --memtest none \
    --debian-installer none \
    --debian-installer-gui false \
    --cache false

"${LB[@]}" build

if [ ! -f live-image-amd64.hybrid.iso ]; then
    echo "live-build did not create live-image-amd64.hybrid.iso" >&2
    exit 1
fi

cp live-image-amd64.hybrid.iso "$ISO_PATH"
sha256sum "$ISO_PATH" > "$ISO_PATH.sha256"

if [ "$(id -u)" -eq 0 ]; then
    owner_uid="$(stat -c '%u' "$ROOT_DIR")"
    owner_gid="$(stat -c '%g' "$ROOT_DIR")"
    chown "$owner_uid:$owner_gid" "$ISO_PATH" "$ISO_PATH.sha256" "$JAR_PATH"
fi

printf 'Created %s\n' "$ISO_PATH"
printf 'Build workspace: %s\n' "$BUILD_ROOT"









