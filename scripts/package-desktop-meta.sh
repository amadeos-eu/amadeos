#!/usr/bin/env bash
# Builds the meta package amadeos-desktop: the whole amadeOS desktop as one package. It holds no files, only
# relations: it depends on the core of the desktop and recommends every program, game and Debian package the
# image brings. The image installs it, and the release on main attaches it, so apt.amadeos.eu offers it. When a
# new version recommends something new (a new program in repositories.list, a new Debian package in the package
# list), apt installs it with the next update; what the user removed stays removed.
#
# The optional games of repositories.list (marked "# optional") are not in the image, so amadeos-desktop only
# suggests them. Systems that got them through an older amadeos-desktop keep them, but "apt autoremove" would
# now offer to remove them (a suggestion does not keep a package); amadeos-games keeps them. That second meta
# package is built by the same run: it recommends every game, optional or not ("sudo apt install
# amadeos-games"); the release attaches it too, but the image does not install it.
#
# Usage: scripts/package-desktop-meta.sh [--install-iso] [--version X.Y.Z] [OUTPUT_DIR]
#
#   --install-iso  put amadeos-desktop into config/packages.chroot/, replacing an older build
#   --version V    the amadeOS version (SemVer, X.Y.Z-dev.N becomes the Debian version X.Y.Z~dev.N);
#                  default AMADEOS_VERSION, else 0.0.0-dev.0
#
# The recommended programs and games come from repositories.list, the Debian packages from
# config/package-lists/amadeos.list.chroot, minus the parts only the live system and the installer need.
# Prints the path of amadeos-games, then that of amadeos-desktop as the last line.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package=amadeos-desktop

out_dir="$root_dir/build"
install_iso=0
version="${AMADEOS_VERSION:-0.0.0-dev.0}"
while [ $# -gt 0 ]; do
    case "$1" in
        --install-iso) install_iso=1 ;;
        --version) shift; version="${1:?--version needs a version}" ;;
        -h|--help) sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) out_dir="$1" ;;
    esac
    shift
done
deb_version="${version//-/\~}"

# Without these the desktop does not start or gets no updates; they are depended on, not recommended.
depends=(amadeos-archive-keyring amadeos-dm amadeos-session amadeos-wm amadeos-panel-cde amadeos-settings
    amadeos-packages)
# The other modules of amadeos-system and the packages the image builds itself (scripts/package-*.sh) or that
# come from the libraries' repositories.
system=(amadeos-panel-horizon amadeos-widgets amadeos-icons-horizon amadeos-java-options amadeos-software amadeos-logviewer
    amadeos-sysinfo amadeos-taskmanager amadeos-print amadeos-disks amadeos-handbook amadeos-backdrops-cde
    nscde-icon-theme amade-app-handbook amade-game-handbook)
# Repositories of repositories.list without a program of their own: the libraries (their handbooks are above),
# the modules of amadeos-system (above) and the installer, which an installed system removes again.
not_programs=" amade-commons amade-game-engine amadeos-system amadeos-installer "
# Debian packages of the package list that only the live system, its boot loaders, the installer and the
# firmware of the image need; an installed system already has its boot loader and firmware.
not_desktop='^(live-boot|live-config|live-config-systemd|user-setup|isolinux|syslinux-.*|squashfs-tools|grub-.*|grub2-common|shim-signed|efibootmgr|os-prober|firmware-.*)$'

programs=()
while read -r repo; do
    case "$not_programs" in *" $repo "*) continue ;; esac
    programs+=("$repo")
done < <("$root_dir/scripts/list-repositories.sh" --image)
mapfile -t optional < <("$root_dir/scripts/list-repositories.sh" --optional)
games=()
while read -r repo; do
    [[ "$repo" == *-game ]] && games+=("$repo")
done < <("$root_dir/scripts/list-repositories.sh" --all)

debian=()
while read -r name; do
    [[ "$name" =~ $not_desktop ]] || debian+=("$name")
done < <(sed 's/#.*//' "$root_dir/config/package-lists/amadeos.list.chroot" | awk 'NF { print $1 }')

join() {
    local IFS=,
    echo "$*" | sed 's/,/, /g'
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
chmod 755 "$work"
mkdir -p "$work/DEBIAN" "$work/usr/share/doc/$package"
cat > "$work/DEBIAN/control" <<EOF
Package: $package
Version: $deb_version
Architecture: all
Section: metapackages
Priority: optional
Maintainer: amadeOS Project <developers@datazuul.com>
Homepage: https://www.amadeos.eu
Depends: $(join "${depends[@]}")
Recommends: $(join "${system[@]}" "${programs[@]}" "${debian[@]}")
Suggests: $(join amadeos-games "${optional[@]}")
Description: amadeOS desktop with all its programs
 Installs the amadeOS desktop: the login screen, the session, the window
 manager, the Front Panel and Settings, together with the programs, games and
 Debian packages of the amadeOS image.
 .
 New programs of a later amadeOS release arrive with the next update. Every
 recommended program can be removed; it stays removed after updates. The
 optional games are only suggested; amadeos-games installs all of them.
EOF
cat > "$work/usr/share/doc/$package/copyright" <<'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: amadeos
Source: https://github.com/amadeos-eu/amadeos

Files: *
Copyright: amadeOS Project
License: EUPL-1.2
EOF

mkdir -p "$out_dir"
deb="$out_dir/${package}_${deb_version}_all.deb"
dpkg-deb --root-owner-group --build "$work" "$deb" >/dev/null

# amadeos-games: every game of repositories.list, the two of the image and the optional ones.
games_work="$(mktemp -d)"
trap 'rm -rf "$work" "$games_work"' EXIT
chmod 755 "$games_work"
mkdir -p "$games_work/DEBIAN" "$games_work/usr/share/doc/amadeos-games"
cp "$work/usr/share/doc/$package/copyright" "$games_work/usr/share/doc/amadeos-games/"
cat > "$games_work/DEBIAN/control" <<EOF
Package: amadeos-games
Version: $deb_version
Architecture: all
Section: metapackages
Priority: optional
Maintainer: amadeOS Project <developers@datazuul.com>
Homepage: https://www.amadeos.eu/games.html
Recommends: $(join "${games[@]}")
Description: all games of amadeOS
 Installs every game written for amadeOS: card and puzzle games, arcade
 games, strategy and building games, a 3D shooter, a driving game, a pinball
 machine and an adventure. The image itself brings only Mines and Solitaire.
 .
 New games of a later amadeOS release arrive with the next update. Every
 game can be removed on its own; it stays removed after updates.
EOF
games_deb="$out_dir/amadeos-games_${deb_version}_all.deb"
dpkg-deb --root-owner-group --build "$games_work" "$games_deb" >/dev/null

if [ "$install_iso" = 1 ]; then
    rm -f "$root_dir/config/packages.chroot/${package}_"*.deb
    mkdir -p "$root_dir/config/packages.chroot"
    cp "$deb" "$root_dir/config/packages.chroot/"
fi
echo "$games_deb"
echo "$deb"
