#!/usr/bin/env bash
# Builds the Debian package amadeos-handbook: the amadeOS User's Handbook (docs/handbook) for reading
# without a network, in /usr/share/doc/amadeos-handbook/html. The Help drawer of the Front Panel opens
# it with xdg-open, so in the web browser (the pages need JavaScript, which amade-web does not have).
#
# Usage: scripts/package-handbook.sh [--install-iso] [OUTPUT_DIR]
#
#   --install-iso  put the package into config/packages.chroot/, replacing an older build
#
# The version is 0.1.0+<date and time of the last commit that changed docs/handbook>, so a changed
# book gives a new version. MkDocs comes from docs/handbook/requirements.txt and is installed into
# docs/handbook/.venv if no mkdocs is on the PATH. Prints the path of the package as its last line.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
handbook_dir="$root_dir/docs/handbook"
package=amadeos-handbook

out_dir="$root_dir/build"
install_iso=0
for arg in "$@"; do
    case "$arg" in
        --install-iso) install_iso=1 ;;
        -h|--help) sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) out_dir="$arg" ;;
    esac
done

stamp="$(git -C "$root_dir" log -1 --format=%cd --date=format:%Y%m%d%H%M -- docs/handbook 2>/dev/null || true)"
version="0.1.0+${stamp:-$(date +%Y%m%d%H%M)}"

mkdocs=mkdocs
if ! command -v mkdocs >/dev/null 2>&1; then
    if [ ! -x "$handbook_dir/.venv/bin/mkdocs" ]; then
        python3 -m venv "$handbook_dir/.venv"
        "$handbook_dir/.venv/bin/pip" install --quiet -r "$handbook_dir/requirements.txt"
    fi
    mkdocs="$handbook_dir/.venv/bin/mkdocs"
fi

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT
doc_dir="$staging/usr/share/doc/$package"
mkdir -p "$doc_dir" "$staging/DEBIAN" "$out_dir"

(cd "$handbook_dir" && "$mkdocs" build --quiet -f mkdocs-offline.yml --site-dir "$doc_dir/html")
cp "$root_dir/LICENSE" "$doc_dir/copyright"

cat > "$staging/DEBIAN/control" <<CONTROL
Package: $package
Version: $version
Section: doc
Priority: optional
Architecture: all
Installed-Size: $(du -sk "$staging/usr" | cut -f1)
Recommends: firefox-esr | www-browser, xdg-utils
Maintainer: amadeOS Project <developers@datazuul.com>
Description: amadeOS User's Handbook
 Why amadeOS, how to install it, how to use and administer it: the
 handbook of the amadeOS desktop for reading without a network. The
 Help drawer of the Front Panel opens it in the web browser.
CONTROL

deb="$out_dir/${package}_${version}_all.deb"
dpkg-deb --root-owner-group --build "$staging" "$deb" >/dev/null
if [ "$install_iso" = 1 ]; then
    mkdir -p "$root_dir/config/packages.chroot"
    rm -f "$root_dir/config/packages.chroot/${package}"_*.deb
    cp "$deb" "$root_dir/config/packages.chroot/"
    deb="$root_dir/config/packages.chroot/$(basename "$deb")"
fi
echo "$deb"
