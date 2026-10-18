#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/config"
ARTIFACT_DIR="$ROOT_DIR/artifacts"
ISO_PATH="$ARTIFACT_DIR/amadeos-amd64.iso"
BUILD_ROOT="${AMADEOS_BUILD_ROOT:-${TMPDIR:-/tmp}/amadeos-live-build}"

# BUILD_ROOT is deleted with sudo before every full build: refuse anything that is not a
# dedicated directory at least two levels deep (e.g. "/", "/home", a relative path).
while [ "${BUILD_ROOT%/}" != "$BUILD_ROOT" ]; do BUILD_ROOT="${BUILD_ROOT%/}"; done
case "$BUILD_ROOT" in
    /?*/?*) ;;
    *) echo "Refusing unsafe build directory '$BUILD_ROOT' (set AMADEOS_BUILD_ROOT to an absolute path like /var/tmp/amadeos-live-build)" >&2; exit 1 ;;
esac

# Only directories this script created (marker file) or with the default name may be wiped,
# so a mistyped AMADEOS_BUILD_ROOT such as /var/tmp or a home directory is never deleted.
BUILD_ROOT_MARKER=".amadeos-build-root"
build_root_is_ours() {
    [ ! -e "$BUILD_ROOT" ] \
        || [ -e "$BUILD_ROOT/$BUILD_ROOT_MARKER" ] \
        || [ "$(basename "$BUILD_ROOT")" = "amadeos-live-build" ] \
        || [ -z "$(ls -A "$BUILD_ROOT" 2>/dev/null)" ]
}

# Lists mount points at or below the build directory (bind mounts of the host's /dev, proc, ...).
mounts_below_build_root() {
    awk -v root="$BUILD_ROOT" '$2 == root || index($2, root "/") == 1 { print $2 }' /proc/self/mounts
}

cd "$ROOT_DIR"

"$ROOT_DIR/scripts/check-config.sh"
command -v lb >/dev/null 2>&1 || { echo "live-build (lb) is required" >&2; exit 1; }

mkdir -p "$ARTIFACT_DIR"
# The desktop is the packages amade-dm, amade-session, amade-wm, amade-panel-cde and amade-style from the
# amade-system repository; like every other package in config/packages.chroot they are installed into the image.
for package in amade-dm amade-session amade-wm amade-panel-cde amade-style; do
    if ! compgen -G "$CONFIG_DIR/packages.chroot/${package}_*.deb" >/dev/null; then
        echo "[build-image] No ${package}_*.deb in config/packages.chroot. Build the desktop packages with" >&2
        echo "    (cd ../amade-system && ./gradlew installToAmadeOs)" >&2
        echo "or build everything with ./buildDistribution.sh." >&2
        exit 1
    fi
done
# NsCDE is the default icon theme (GPL-3.0, own package nscde-icon-theme); build it if missing or
# older than the version in package-nscde-icons.sh (PACKAGE_REVISION is bumped when icons/NsCDE changes).
# Without it the desktop falls back to hicolor and to icons drawn in Java.
ICONS_SCRIPT="$ROOT_DIR/scripts/package-nscde-icons.sh"
ICONS_VERSION="$(sed -n 's/^NSCDE_VERSION="\(.*\)"$/\1/p' "$ICONS_SCRIPT")-$(sed -n 's/^PACKAGE_REVISION="\(.*\)"$/\1/p' "$ICONS_SCRIPT")"
if [ ! -f "$CONFIG_DIR/packages.chroot/nscde-icon-theme_${ICONS_VERSION}_all.deb" ]; then
    "$ROOT_DIR/scripts/package-nscde-icons.sh" --deb-only --install-iso \
        || echo "[build-image] Warning: nscde-icon-theme could not be built; continuing without the default icon theme." >&2
fi
# The original CDE backdrops are LGPL and live in their own package (amadeos-backdrops-cde);
# build it once if it is not in config/packages.chroot yet. Without it the image just lacks the patterns.
if ! compgen -G "$CONFIG_DIR/packages.chroot/amadeos-backdrops-cde_*.deb" >/dev/null; then
    "$ROOT_DIR/scripts/package-cde-backdrops.sh" --install-iso \
        || echo "[build-image] Warning: amadeos-backdrops-cde could not be built; continuing without CDE backdrops." >&2
fi
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER:" "$ARTIFACT_DIR" 2>/dev/null || true
fi

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    command -v sudo >/dev/null 2>&1 || { echo "sudo is required for live-build" >&2; exit 1; }
    SUDO="sudo"
fi

# The live-config settings (user, groups, keyboard, time zone, host name) live in
# config/includes.chroot/etc/live/config.conf; the kernel command line would override them, so it only
# starts live-config. Both boot loaders (isolinux and the UEFI GRUB below) get the same two lines.
BOOTAPPEND="boot=live components"
BOOTAPPEND_FAILSAFE="memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal"

# Fills the isolinux menu template the way live-build does (one kernel flavour), so that the quick
# repack mode ends up with the same boot menu as a full build.
render_live_cfg() {
    sed -e "s|@FLAVOUR@|amd64|g" \
        -e "s|@KERNEL@|/live/vmlinuz|g" \
        -e "s|@INITRD@|/live/initrd.img|g" \
        -e "s|@LB_BOOTAPPEND_LIVE@|$BOOTAPPEND|g" \
        -e "s|@LB_BOOTAPPEND_FAILSAFE@|$BOOTAPPEND_FAILSAFE|g" \
        "$CONFIG_DIR/bootloaders/isolinux/live.cfg.in"
}

if [ "${AMADEOS_PACKAGE_ONLY:-0}" = "1" ]; then
    echo "[build-image] Package-only mode requested; packaging existing $BUILD_ROOT/binary..."
    cd "$BUILD_ROOT"
elif [ "${AMADEOS_QUICK:-0}" = "1" ] || [ "${AMADEOS_REPACK_ROOTFS:-0}" = "1" ]; then
    if [ ! -d "$BUILD_ROOT/chroot" ] || [ ! -d "$BUILD_ROOT/binary" ]; then
        echo "[build-image] Quick repack mode requires existing $BUILD_ROOT/chroot and $BUILD_ROOT/binary. Run full build first." >&2
        exit 1
    fi
    # The quick mode only reinstalls the .deb files of config/packages.chroot; a package added to the
    # package list since the chroot was built needs a full build, so stop here instead of making an image
    # without it (apt has no lists in the chroot, so it cannot be fetched now either).
    missing_packages=""
    for package in $(sed 's/#.*//' "$CONFIG_DIR/package-lists/amadeos.list.chroot"); do
        if [ "$($SUDO chroot "$BUILD_ROOT/chroot" dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null)" != "installed" ]; then
            missing_packages="$missing_packages $package"
        fi
    done
    if [ -n "$missing_packages" ]; then
        echo "[build-image] Quick repack mode cannot add packages from config/package-lists/amadeos.list.chroot;" >&2
        echo "    not in the chroot yet:$missing_packages" >&2
        echo "    Run a full build (sudo ./build.sh) instead." >&2
        exit 1
    fi
    echo "[build-image] Quick repack mode: syncing includes into chroot and rebuilding squashfs..."
    $SUDO cp -a "$CONFIG_DIR/includes.chroot/." "$BUILD_ROOT/chroot/"
    # The same permissions and services as in a full build: the hook, run in the chroot.
    $SUDO chroot "$BUILD_ROOT/chroot" sh -s < "$CONFIG_DIR/hooks/normal/010-amadeos-permissions.chroot"

    # Install drop-in packages from config/packages.chroot if present
    if compgen -G "$CONFIG_DIR/packages.chroot/*.deb" >/dev/null; then
        echo "[build-image] Installing drop-in packages from packages.chroot into chroot..."
        $SUDO cp "$CONFIG_DIR/packages.chroot/"*.deb "$BUILD_ROOT/chroot/tmp/"
        # Let dpkg report problems; apt-get -f then pulls in missing dependencies and fails the build if it cannot.
        $SUDO chroot "$BUILD_ROOT/chroot" sh -c 'dpkg -i /tmp/*.deb || apt-get install -f -y'
        $SUDO rm -f "$BUILD_ROOT/chroot/tmp/"*.deb
    fi
    # The boot menu with the current kernel command line (the locales were generated by the full build).
    if [ -d "$BUILD_ROOT/binary/isolinux" ]; then
        render_live_cfg | $SUDO tee "$BUILD_ROOT/binary/isolinux/live.cfg" >/dev/null
    fi
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
    if ! build_root_is_ours; then
        echo "Refusing to delete $BUILD_ROOT: it is not empty and was not created by this script ($BUILD_ROOT_MARKER missing)" >&2
        exit 1
    fi
    # Never delete while something is still mounted inside: with the host's /dev bound into the
    # chroot, rm -rf would delete the host's device nodes.
    if [ -n "$(mounts_below_build_root)" ]; then
        echo "Still mounted below $BUILD_ROOT, refusing to delete it:" >&2
        mounts_below_build_root >&2
        exit 1
    fi
    $SUDO rm -rf --one-file-system "$BUILD_ROOT"
    mkdir -p "$BUILD_ROOT"
    touch "$BUILD_ROOT/$BUILD_ROOT_MARKER"
    cp -a "$CONFIG_DIR" "$BUILD_ROOT/config"
    # The hooks are in config/hooks/normal, where Debian's live-build runs them; live-build 3.0
    # (Ubuntu) runs config/hooks/*.chroot, so link them there in the build copy.
    for hook in "$BUILD_ROOT/config/hooks/normal/"*.chroot; do
        ln -s "normal/$(basename "$hook")" "$BUILD_ROOT/config/hooks/$(basename "$hook")"
    done

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
        --bootappend-failsafe "$BOOTAPPEND_FAILSAFE" \
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

    # live-build 3.0 attempts to sign drop-in packages in config/packages.chroot using gpg inside chroot.
    # On modern Debian releases (trixie/bookworm), gpg is not present in minimal bootstrap and deprecated.
    # Patch lb_chroot_archives to treat local packages as [trusted=yes] and skip in-chroot GPG key generation.
    if grep -q 'echo "deb file:/root/packages ./" > chroot/etc/apt/sources.list.d/packages.list' /usr/lib/live/build/lb_chroot_archives 2>/dev/null; then
        $SUDO sed -i 's|echo "deb file:/root/packages ./" > chroot/etc/apt/sources.list.d/packages.list|echo "deb [trusted=yes] file:/root/packages ./" > chroot/etc/apt/sources.list.d/packages.list|' /usr/lib/live/build/lb_chroot_archives 2>/dev/null || true
    fi
    if grep -q 'Chroot chroot "gpg --batch --gen-key"' /usr/lib/live/build/lb_chroot_archives 2>/dev/null && \
       ! grep -q 'if false && \[ "\${LB_APT_SECURE}" = "true" \]' /usr/lib/live/build/lb_chroot_archives 2>/dev/null; then
        $SUDO sed -i 's|if \[ "\${LB_APT_SECURE}" = "true" \]|if false \&\& [ "${LB_APT_SECURE}" = "true" ]|' /usr/lib/live/build/lb_chroot_archives 2>/dev/null || true
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

menuentry "amadeOS Live (amd64 UEFI)" {
    linux /live/vmlinuz $BOOTAPPEND
    initrd /live/initrd.img
}

menuentry "amadeOS Live (amd64 UEFI failsafe)" {
    linux /live/vmlinuz $BOOTAPPEND $BOOTAPPEND_FAILSAFE
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
    mkfs.fat -F 16 -n "AMADEOS_EFI" "$BUILD_ROOT/efi.img"
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
            -volid "amadeos" \
            -appid "amadeOS Live" \
            -publisher "amadeOS" \
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
    chown "$owner_uid:$owner_gid" "$ISO_PATH" "$ISO_PATH.sha256"
fi

printf 'Created %s\n' "$ISO_PATH"
printf 'Build workspace: %s\n' "$BUILD_ROOT"
