#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/config"
ARTIFACT_DIR="$ROOT_DIR/artifacts"
JAR_PATH="$CONFIG_DIR/includes.chroot/opt/dazeos/dazeos-demo.jar"
ISO_PATH="$ARTIFACT_DIR/dazeos-amd64.iso"
BUILD_ROOT="${DAZEOS_BUILD_ROOT:-${TMPDIR:-/tmp}/dazeos-live-build}"

cd "$ROOT_DIR"

export PATH="$PATH:/snap/bin"
command -v gradle >/dev/null 2>&1 || { echo "gradle is required" >&2; exit 1; }
command -v lb >/dev/null 2>&1 || { echo "live-build (lb) is required" >&2; exit 1; }

mkdir -p "$ARTIFACT_DIR" "$(dirname "$JAR_PATH")"
gradle clean jar
cp build/libs/dazeos-*.jar "$JAR_PATH"

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    command -v sudo >/dev/null 2>&1 || { echo "sudo is required for live-build" >&2; exit 1; }
    SUDO="sudo"
fi

for mount_point in \
    "$BUILD_ROOT/chroot/dev/pts" \
    "$BUILD_ROOT/chroot/dev" \
    "$BUILD_ROOT/chroot/proc" \
    "$BUILD_ROOT/chroot/sys"; do
    $SUDO umount -R -lf "$mount_point" 2>/dev/null || true
done
$SUDO rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"
cp -a "$CONFIG_DIR" "$BUILD_ROOT/config"
cp -a "$JAR_PATH" "$BUILD_ROOT/config/includes.chroot/opt/dazeos/dazeos-demo.jar"

cd "$BUILD_ROOT"
rm -rf chroot binary cache

# Modern tmpfs /tmp is mounted with nodev, which prevents opening newly created
# device nodes like /dev/null with EACCES (13: Permission denied).
# Bind the host distribution's /dev so package post-install scripts and APT can use /dev/null.
mkdir -p "$BUILD_ROOT/chroot/dev"
$SUDO mount --bind /dev "$BUILD_ROOT/chroot/dev"

cleanup_dev_mount() {
    $SUDO umount -R -lf "$BUILD_ROOT/chroot/dev" 2>/dev/null || true
}
trap cleanup_dev_mount EXIT

LB=($SUDO lb)

"${LB[@]}" config \
    --mode debian \
    --distribution trixie \
    --architectures amd64 \
    --initsystem systemd \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components username=dazeos hostname=dazeos" \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap http://deb.debian.org/debian \
    --mirror-chroot http://deb.debian.org/debian \
    --mirror-binary http://deb.debian.org/debian \
    --parent-mirror-bootstrap http://deb.debian.org/debian \
    --parent-mirror-chroot http://deb.debian.org/debian \
    --parent-mirror-binary http://deb.debian.org/debian \
    --security false \
    --apt-recommends false \
    --firmware-chroot false \
    --firmware-binary false \
    --memtest none \
    --debian-installer false \
    --debian-installer-gui false \
    --cache false

# Ubuntu's live-build 3.0 contains a downstream bug in lb_binary_syslinux where it
# unconditionally redirects from ${_TARGET}/bootlogo even in Debian mode where gfxboot is not used.
if grep -q '< \${_TARGET}/bootlogo' /usr/lib/live/build/lb_binary_syslinux 2>/dev/null && \
   ! grep -q 'if \[ -e "\${_TARGET}/bootlogo" \]; then' /usr/lib/live/build/lb_binary_syslinux 2>/dev/null; then
    $SUDO sed -i 's|tmpdir="\$(mktemp -d)"|if [ -e "\${_TARGET}/bootlogo" ]; then\n&|; s|rm -rf "\$tmpdir"|&\nfi|' /usr/lib/live/build/lb_binary_syslinux 2>/dev/null || true
fi

if grep -q 'Check_package chroot/usr/bin/isohybrid syslinux$' /usr/lib/live/build/lb_binary_iso 2>/dev/null; then
    $SUDO sed -i 's|Check_package chroot/usr/bin/isohybrid syslinux|Check_package chroot/usr/bin/isohybrid syslinux-utils|' /usr/lib/live/build/lb_binary_iso 2>/dev/null || true
fi

"${LB[@]}" build

OUTPUT_ISO=""
for candidate in binary.hybrid.iso live-image-amd64.hybrid.iso binary.iso live-image-amd64.iso; do
    if [ -f "$candidate" ]; then
        OUTPUT_ISO="$candidate"
        break
    fi
done

if [ -z "$OUTPUT_ISO" ]; then
    echo "live-build did not create an ISO image" >&2
    exit 1
fi

cp "$OUTPUT_ISO" "$ISO_PATH"
sha256sum "$ISO_PATH" > "$ISO_PATH.sha256"

if [ "$(id -u)" -eq 0 ]; then
    owner_uid="$(stat -c '%u' "$ROOT_DIR")"
    owner_gid="$(stat -c '%g' "$ROOT_DIR")"
    chown "$owner_uid:$owner_gid" "$ISO_PATH" "$ISO_PATH.sha256" "$JAR_PATH"
fi

printf 'Created %s\n' "$ISO_PATH"
printf 'Build workspace: %s\n' "$BUILD_ROOT"









