#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# package-cde-backdrops.sh
#
# Fetches the original CDE backdrops (X pixmaps .pm and bitmaps .bm) from the
# CDE sources and packages them as the Debian package amadeos-backdrops-cde,
# installed to /usr/share/amadeos/backdrops/cde. The Style Manager lists them
# and colours them from the backdrop colour, as dtstyle does.
#
# CDE is licensed under the LGPL (version 2 or later). Keeping the backdrops in
# their own package leaves the desktop packages and this repository purely EUPL-1.2; the
# package carries the CDE copyright notices and licence in
# /usr/share/doc/amadeos-backdrops-cde/copyright.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts"

# The CDE project's repository on SourceForge, with its GitHub mirror as fallback.
CDE_REPOS=("${CDE_REPO:-https://git.code.sf.net/p/cdesktopenv/code}" "https://github.com/cdesktopenv/cde.git")
CDE_TAG="${CDE_TAG:-2.5.3}"
PACKAGE_NAME="amadeos-backdrops-cde"
PACKAGE_VERSION="${CDE_TAG}-1"
INSTALL_DIR="usr/share/amadeos/backdrops/cde"
# NoBackdrop is the Style Manager's plain colour entry; SunLogo is a vendor trademark.
EXCLUDE=("NoBackdrop.bm" "NoBackdrop.pm" "SunLogo.pm")

INSTALL_ISO=false
INSTALL_LOCAL=false

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    --install-iso     Also place the .deb into config/packages.chroot/ for the live image
    --install-local   Also copy the backdrops to \${XDG_CONFIG_HOME:-~/.config}/amadeos/backdrops/cde
    --help, -h        Show this help message

Environment:
    CDE_REPO          CDE git repository (default: SourceForge, GitHub mirror as fallback)
    CDE_TAG           CDE release tag to take the backdrops from (default: $CDE_TAG)

Output:
    artifacts/${PACKAGE_NAME}_${PACKAGE_VERSION}_all.deb
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install-iso) INSTALL_ISO=true; shift ;;
        --install-local) INSTALL_LOCAL=true; shift ;;
        --help|-h) show_help ;;
        *) echo "Unknown option: $1" >&2; show_help ;;
    esac
done

command -v dpkg-deb >/dev/null 2>&1 || { echo "dpkg-deb is required" >&2; exit 1; }

TMP_DIR="$(mktemp -d /tmp/cde-backdrops-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> [1/3] Fetching the backdrops of CDE $CDE_TAG..."
CLONE_DIR="$TMP_DIR/cde"
fetched=false
for repo in "${CDE_REPOS[@]}"; do
    rm -rf "$CLONE_DIR"
    if git clone --quiet --depth 1 --branch "$CDE_TAG" --filter=blob:none --sparse "$repo" "$CLONE_DIR" 2>/dev/null; then
        git -C "$CLONE_DIR" sparse-checkout set cde/programs/backdrops
        echo "    from $repo"
        fetched=true
        break
    fi
    echo "    $repo not reachable, trying the next source..."
done
[ "$fetched" = true ] || { echo "Error: could not fetch the CDE sources" >&2; exit 1; }

SRC="$CLONE_DIR/cde/programs/backdrops"
COMMIT="$(git -C "$CLONE_DIR" rev-parse HEAD)"
[ -f "$CLONE_DIR/cde/COPYING" ] || { echo "Error: cde/COPYING missing" >&2; exit 1; }

echo "==> [2/3] Building $PACKAGE_NAME $PACKAGE_VERSION..."
DEB_ROOT="$TMP_DIR/deb"
DEST="$DEB_ROOT/$INSTALL_DIR"
DOC="$DEB_ROOT/usr/share/doc/$PACKAGE_NAME"
mkdir -p "$DEST" "$DOC" "$DEB_ROOT/DEBIAN"
count=0
for f in "$SRC"/*.pm "$SRC"/*.bm; do
    name="$(basename "$f")"
    skip=false
    for x in "${EXCLUDE[@]}"; do [ "$name" = "$x" ] && skip=true; done
    [ "$skip" = true ] && continue
    install -m 0644 "$f" "$DEST/$name"
    count=$((count + 1))
done
[ "$count" -gt 0 ] || { echo "Error: no backdrops found in $SRC" >&2; exit 1; }

# Machine-readable copyright (DEP-5); the full LGPL texts ship with base-files.
cat > "$DOC/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: CDE - Common Desktop Environment
Upstream-Contact: https://sourceforge.net/projects/cdesktopenv/
Source: https://sourceforge.net/p/cdesktopenv/code/ (tag $CDE_TAG, commit $COMMIT, cde/programs/backdrops)
Comment: Unmodified backdrops of CDE. NoBackdrop and SunLogo are not included.

Files: $INSTALL_DIR/*
Copyright: 1990, 1993, 1994 Hewlett-Packard Company
 1993, 1994 International Business Machines Corp.
 1993, 1994 Sun Microsystems, Inc.
 1993, 1994 Unix System Labs, Inc., a subsidiary of Novell, Inc.
License: LGPL-2+

License: LGPL-2+
 This library is free software; you can redistribute it and/or modify it under
 the terms of the GNU Library General Public License as published by the Free
 Software Foundation; either version 2 of the License, or (at your option) any
 later version.
 .
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Library General Public License for more details.
 .
 On Debian systems, the complete texts of the GNU Library General Public License
 version 2 and the GNU Lesser General Public License versions 2.1 and 3 can be
 found in /usr/share/common-licenses/LGPL-2, LGPL-2.1 and LGPL-3.
EOF
# The upstream licence file as shipped by CDE, for systems without base-files.
install -m 0644 "$CLONE_DIR/cde/COPYING" "$DOC/COPYING"

INSTALLED_SIZE="$(du -sk "$DEB_ROOT/usr" | cut -f1)"
cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION
Section: x11
Priority: optional
Architecture: all
Installed-Size: $INSTALLED_SIZE
Maintainer: amadeOS Project <info@amadeos.org>
Homepage: https://github.com/datazuul/amadeos
Description: original CDE backdrops for the amadeOS desktop
 The pattern backdrops of the Common Desktop Environment (Pebbles, Concave,
 BrickWall, Toronto, WaterDrops, ...) as X pixmaps and bitmaps. The amadeOS
 Style Manager lists them under Backdrop and colours them from the chosen
 backdrop colour, as CDE's dtstyle does.
EOF

mkdir -p "$ARTIFACTS_DIR"
DEB_OUT="$ARTIFACTS_DIR/${PACKAGE_NAME}_${PACKAGE_VERSION}_all.deb"
dpkg-deb --root-owner-group --build "$DEB_ROOT" "$DEB_OUT" >/dev/null
echo "    Created: $DEB_OUT ($count backdrops, $(du -h "$DEB_OUT" | cut -f1))"

echo "==> [3/3] Installation targets..."
if [ "$INSTALL_ISO" = true ]; then
    mkdir -p "$ROOT_DIR/config/packages.chroot"
    cp -f "$DEB_OUT" "$ROOT_DIR/config/packages.chroot/"
    echo "    Copied into config/packages.chroot/"
fi
if [ "$INSTALL_LOCAL" = true ]; then
    LOCAL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/amadeos/backdrops/cde"
    mkdir -p "$LOCAL_DIR"
    cp -f "$DEST"/* "$LOCAL_DIR/"
    echo "    Copied into $LOCAL_DIR"
fi
echo "==> Done."
