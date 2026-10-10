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
if [ -x "$ROOT_DIR/gradlew" ]; then
    GRADLE_BIN="$ROOT_DIR/gradlew"
else
    command -v gradle >/dev/null 2>&1 || { echo "gradle is required" >&2; exit 1; }
    GRADLE_BIN="gradle"
fi
command -v lb >/dev/null 2>&1 || { echo "live-build (lb) is required" >&2; exit 1; }

mkdir -p "$ARTIFACT_DIR" "$(dirname "$JAR_PATH")"
"$GRADLE_BIN" clean jar
cp build/libs/dazeos-*.jar "$JAR_PATH"
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER:" "$ROOT_DIR/build" "$JAR_PATH" "$ARTIFACT_DIR" 2>/dev/null || true
fi

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    command -v sudo >/dev/null 2>&1 || { echo "sudo is required for live-build" >&2; exit 1; }
    SUDO="sudo"
fi

BOOTAPPEND="boot=live components username=dazeos user-password=dazeos hostname=dazeos user-default-groups=audio,cdrom,dip,floppy,video,plugdev,netdev,powerdev,scanner,bluetooth,sudo,input"

if [ "${DAZEOS_PACKAGE_ONLY:-0}" = "1" ]; then
    echo "[build-image] Package-only mode requested; packaging existing $BUILD_ROOT/binary..."
    cd "$BUILD_ROOT"
elif [ "${DAZEOS_QUICK:-0}" = "1" ] || [ "${DAZEOS_REPACK_ROOTFS:-0}" = "1" ]; then
    if [ ! -d "$BUILD_ROOT/chroot" ] || [ ! -d "$BUILD_ROOT/binary" ]; then
        echo "[build-image] Quick repack mode requires existing $BUILD_ROOT/chroot and $BUILD_ROOT/binary. Run full build first." >&2
        exit 1
    fi
    echo "[build-image] Quick repack mode: syncing includes into chroot and rebuilding squashfs..."
    $SUDO cp -a "$CONFIG_DIR/includes.chroot/." "$BUILD_ROOT/chroot/"
    $SUDO chmod 0755 "$BUILD_ROOT/chroot/usr/local/bin/dazeos-dm" 2>/dev/null || true
    $SUDO chmod 0755 "$BUILD_ROOT/chroot/usr/local/bin/dazeos-session" 2>/dev/null || true
    $SUDO rm -f "$BUILD_ROOT/binary/live/filesystem.squashfs"
    $SUDO mksquashfs "$BUILD_ROOT/chroot" "$BUILD_ROOT/binary/live/filesystem.squashfs" -comp xz -noappend
    cd "$BUILD_ROOT"
else
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
        --bootappend-live "$BOOTAPPEND" \
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
fi

# Reclaim ownership of binary directory for non-root build operations if needed
if [ -n "$SUDO" ] && [ -d "$BUILD_ROOT/binary" ]; then
    $SUDO chown -R "$(id -u):$(id -g)" "$BUILD_ROOT/binary"
fi

# Enhance ISO with UEFI bootloader support (Dual-Firmware: BIOS + UEFI)
if command -v grub-mkstandalone >/dev/null 2>&1 && \
   command -v xorriso >/dev/null 2>&1 && \
   command -v mkfs.fat >/dev/null 2>&1 && \
   command -v mcopy >/dev/null 2>&1 && \
   [ -d "$BUILD_ROOT/binary" ]; then
    echo "[build-image] Configuring dual-firmware (UEFI + BIOS) hybrid boot..."
    
    mkdir -p "$BUILD_ROOT/binary/boot/grub" "$BUILD_ROOT/binary/EFI/BOOT"
    
    # Copy GRUB EFI modules if available
    if [ -d "/usr/lib/grub/x86_64-efi" ]; then
        cp -a "/usr/lib/grub/x86_64-efi" "$BUILD_ROOT/binary/boot/grub/"
    elif [ -d "$BUILD_ROOT/chroot/usr/lib/grub/x86_64-efi" ]; then
        cp -a "$BUILD_ROOT/chroot/usr/lib/grub/x86_64-efi" "$BUILD_ROOT/binary/boot/grub/"
    fi
    
    # Write UEFI GRUB configuration matching live boot parameters
    cat > "$BUILD_ROOT/binary/boot/grub/grub.cfg" << EOF
set default=0
set timeout=5

search --file --no-floppy --set=root /live/vmlinuz

menuentry "DazeOS Live (amd64 UEFI)" {
    linux /live/vmlinuz $BOOTAPPEND
    initrd /live/initrd.img
}

menuentry "DazeOS Live (amd64 UEFI failsafe)" {
    linux /live/vmlinuz $BOOTAPPEND memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal
    initrd /live/initrd.img
}
EOF

    # Generate early standalone GRUB configuration
    cat > "$BUILD_ROOT/grub-early.cfg" << 'EOF'
set prefix=(memdisk)/boot/grub
insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660
insmod search
insmod search_fs_file
insmod normal
insmod configfile
insmod linux
insmod all_video

search --file --no-floppy --set=root /live/vmlinuz
set prefix=($root)/boot/grub
configfile ($root)/boot/grub/grub.cfg
EOF

    # Build standalone 64-bit EFI executable
    grub-mkstandalone \
        -O x86_64-efi \
        -o "$BUILD_ROOT/BOOTX64.EFI" \
        "boot/grub/grub.cfg=$BUILD_ROOT/grub-early.cfg"

    cp "$BUILD_ROOT/BOOTX64.EFI" "$BUILD_ROOT/binary/EFI/BOOT/BOOTX64.EFI"

    # Create FAT EFI boot image
    truncate -s 16M "$BUILD_ROOT/efi.img"
    mkfs.fat -F 16 -n "DAZEOS_EFI" "$BUILD_ROOT/efi.img"
    mmd -i "$BUILD_ROOT/efi.img" ::/EFI ::/EFI/BOOT
    mcopy -i "$BUILD_ROOT/efi.img" "$BUILD_ROOT/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI
    cp "$BUILD_ROOT/efi.img" "$BUILD_ROOT/binary/boot/grub/efi.img"

    # Locate isohybrid MBR
    ISOHDPFX=""
    for candidate_mbr in \
        "$BUILD_ROOT/chroot/usr/lib/ISOLINUX/isohdpfx.bin" \
        "/usr/lib/ISOLINUX/isohdpfx.bin"; do
        if [ -f "$candidate_mbr" ]; then
            ISOHDPFX="$candidate_mbr"
            break
        fi
    done

    if [ -n "$ISOHDPFX" ]; then
        echo "[build-image] Creating dual-firmware hybrid ISO with xorriso..."
        rm -f "$BUILD_ROOT"/binary*.iso "$BUILD_ROOT"/live-image*.iso
        xorriso -as mkisofs \
            -iso-level 3 \
            -full-iso9660-filenames \
            -volid "dazeos" \
            -appid "DazeOS Live" \
            -publisher "DazeOS" \
            -isohybrid-mbr "$ISOHDPFX" \
            -eltorito-boot isolinux/isolinux.bin \
            -eltorito-catalog isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -eltorito-alt-boot \
            -e boot/grub/efi.img \
            -no-emul-boot \
            -isohybrid-gpt-basdat \
            -follow-links \
            -output "$BUILD_ROOT/binary.hybrid.iso" \
            "$BUILD_ROOT/binary"
    fi
fi

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









