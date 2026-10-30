#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# package-nscde-icons.sh
#
# Downloads the authentic NsCDE Motif/CDE icon theme from upstream GitHub,
# preserves the upstream GPLv3 license and attribution, and packages it
# as a standalone distributable archive (.tar.xz) and/or Debian package (.deb).
#
# Keeping this as a separate package allows amadeOS to remain cleanly decoupled
# and choose its own license without GPL contamination of the Java codebase.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts"
CHROOT_ICONS_DIR="$ROOT_DIR/config/includes.chroot/usr/share/icons/NsCDE"
USER_ICONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/NsCDE"

NSCDE_REPO="https://github.com/NsCDE/NsCDE.git"
NSCDE_VERSION="2.3"
# Bump when the amadeOS additions in icons/NsCDE change
PACKAGE_REVISION="3"
PACKAGE_VERSION="${NSCDE_VERSION}-${PACKAGE_REVISION}"
PACKAGE_NAME="nscde-icon-theme"
# amadeOS's own icons (EUPL-1.2), merged into the theme under amadeos-* names
AMADEOS_ICONS_DIR="$ROOT_DIR/icons/NsCDE"

BUILD_DEB=true
BUILD_TAR=true
INSTALL_CHROOT=false
INSTALL_LOCAL=false
INSTALL_ISO=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --all             Build both .deb and .tar.xz packages in artifacts/ (default)
    --deb-only        Build only Debian package (.deb)
    --tar-only        Build only tarball (.tar.xz)
    --install-iso     Place .deb into config/packages.chroot/ for live-build ISO inclusion
    --install-chroot  Install theme directly into config/includes.chroot/usr/share/icons/NsCDE
    --install-local   Install theme into current user's ~/.local/share/icons/NsCDE
    --help, -h        Show this help message

Output:
    artifacts/nscde-icon-theme_${PACKAGE_VERSION}_all.deb
    artifacts/nscde-icon-theme-${PACKAGE_VERSION}.tar.xz
EOF
    exit 0
}

# Parse command line flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            BUILD_DEB=true
            BUILD_TAR=true
            shift
            ;;
        --deb-only)
            BUILD_DEB=true
            BUILD_TAR=false
            shift
            ;;
        --tar-only)
            BUILD_DEB=false
            BUILD_TAR=true
            shift
            ;;
        --install-iso)
            BUILD_DEB=true
            INSTALL_ISO=true
            shift
            ;;
        --install-chroot)
            INSTALL_CHROOT=true
            shift
            ;;
        --install-local)
            INSTALL_LOCAL=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            ;;
    esac
done

TMP_DIR="$(mktemp -d /tmp/nscde-icons-XXXXXX)"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "==> [1/4] Fetching NsCDE icon theme from upstream GitHub..."
CLONE_DIR="$TMP_DIR/nscde-repo"
mkdir -p "$CLONE_DIR"
git clone --depth 1 --filter=blob:none --sparse "$NSCDE_REPO" "$CLONE_DIR"
(
    cd "$CLONE_DIR"
    git sparse-checkout set xdg/icons/NsCDE
)

SRC_ICONS="$CLONE_DIR/xdg/icons/NsCDE"
if [ ! -f "$SRC_ICONS/index.theme" ]; then
    echo "Error: index.theme not found in downloaded NsCDE icons!" >&2
    exit 1
fi

# Bundle license & attribution in the icon theme root
cp "$CLONE_DIR/COPYING" "$SRC_ICONS/LICENSE.GPL-3.0"
cat <<'EOF' > "$SRC_ICONS/AUTHORS"
NsCDE Icon Theme
================
Upstream: https://github.com/NsCDE/NsCDE
Project: NsCDE (Not so Common Desktop Environment)
Author: Hegel3DReloaded and contributors
License: GNU General Public License v3.0 (GPL-3.0-only)

Adapted from classic Common Desktop Environment (CDE) and Motif aesthetics
into standard Freedesktop.org XDG icon naming specification.
EOF

# Add amadeOS's own icons; they use amadeos-* names, so no upstream icon is replaced
if [ -d "$AMADEOS_ICONS_DIR" ]; then
    cp -a "$AMADEOS_ICONS_DIR/." "$SRC_ICONS/"
    cat <<'EOF' >> "$SRC_ICONS/AUTHORS"

amadeOS additions
=================
The amadeos-* icons are part of amadeOS (https://github.com/amadeos-eu/amadeos)
and licensed under the European Union Public Licence v1.2 (EUPL-1.2).
EOF
fi

mkdir -p "$ARTIFACTS_DIR"

if [ "$BUILD_TAR" = true ]; then
    echo "==> [2/4] Packaging .tar.xz archive..."
    TAR_OUT="$ARTIFACTS_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.xz"
    tar -C "$CLONE_DIR/xdg/icons" -cJf "$TAR_OUT" NsCDE
    echo "    Created: $TAR_OUT ($(du -h "$TAR_OUT" | cut -f1))"
fi

if [ "$BUILD_DEB" = true ]; then
    echo "==> [3/4] Building standalone Debian package (.deb)..."
    DEB_ROOT="$TMP_DIR/deb-pkg"
    DEB_INSTALL_DIR="$DEB_ROOT/usr/share/icons/NsCDE"
    mkdir -p "$DEB_INSTALL_DIR" "$DEB_ROOT/DEBIAN"

    cp -a "$SRC_ICONS/." "$DEB_INSTALL_DIR/"

    cat <<EOF > "$DEB_ROOT/DEBIAN/control"
Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}
Section: x11
Priority: optional
Architecture: all
Maintainer: amadeOS Project <info@amadeos.org>
Description: Authentic NsCDE CDE/Motif icon theme for Linux
 Complete Freedesktop.org icon theme featuring classic CDE/Motif
 3D beveled aesthetics across 16x16, 22x22, 24x24, 32x32, 48x48,
 and 256x256 resolutions.
EOF

    DEB_OUT="$ARTIFACTS_DIR/${PACKAGE_NAME}_${PACKAGE_VERSION}_all.deb"
    dpkg-deb --build "$DEB_ROOT" "$DEB_OUT" >/dev/null
    echo "    Created: $DEB_OUT ($(du -h "$DEB_OUT" | cut -f1))"
fi

echo "==> [4/4] Installation targets..."
if [ "$INSTALL_ISO" = true ]; then
    PACKAGES_CHROOT_DIR="$ROOT_DIR/config/packages.chroot"
    mkdir -p "$PACKAGES_CHROOT_DIR"
    # Replace older builds, so live-build does not see two versions
    rm -f "${PACKAGES_CHROOT_DIR:?}/${PACKAGE_NAME:?}"_*_all.deb
    cp -f "$DEB_OUT" "$PACKAGES_CHROOT_DIR/"
    echo "    Copied .deb into live ISO drop-in directory: $PACKAGES_CHROOT_DIR/$(basename "$DEB_OUT")"
fi

if [ "$INSTALL_CHROOT" = true ]; then
    echo "    Installing into live ISO chroot ($CHROOT_ICONS_DIR)..."
    mkdir -p "$(dirname "$CHROOT_ICONS_DIR")"
    rm -rf "$CHROOT_ICONS_DIR"
    cp -a "$SRC_ICONS" "$CHROOT_ICONS_DIR"
    echo "    Installed in includes.chroot."
fi

if [ "$INSTALL_LOCAL" = true ]; then
    echo "    Installing into user directory ($USER_ICONS_DIR)..."
    mkdir -p "$(dirname "$USER_ICONS_DIR")"
    rm -rf "$USER_ICONS_DIR"
    cp -a "$SRC_ICONS" "$USER_ICONS_DIR"
    echo "    Installed in user XDG icons."
fi

echo "==> Done. NsCDE icon theme packaged successfully."
