#!/usr/bin/env bash
# Takes the screenshots of the amadeOS User's Handbook on a virtual screen (Xvfb), so that they can be
# renewed whenever the desktop changes: always 1280x800, theme Warm Motif, language English, the demo
# home of docs/handbook/screenshots/home.
#
# Usage: docs/handbook/screenshots/shoot.sh [--install] [SCENE...]
#
#   --install  first install the packages of config/packages.chroot/ (buildDistribution.sh builds
#              them) with apt, add the demo user alex and make the installer believe it runs on the
#              live system; needs root, so run it in a container or a throw-away machine
#   SCENE      only these scenes (see scenes.sh); default: all
#
# Needs: Xvfb, xdotool, ImageMagick (import, convert) and the amadeOS packages installed. The
# pictures go to docs/handbook/chapters/images/<chapter>/<name>.jpg.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "$here/../../.." && pwd)"
images_dir="$root_dir/docs/handbook/chapters/images"

install=0
scenes=()
for arg in "$@"; do
    case "$arg" in
        --install) install=1 ;;
        -h|--help) sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) scenes+=("$arg") ;;
    esac
done

for tool in Xvfb xdotool xwininfo xdpyinfo import convert; do
    command -v "$tool" >/dev/null 2>&1 || { echo "shoot.sh: $tool is missing (packages xvfb, xdotool, x11-utils, imagemagick)" >&2; exit 1; }
done

# --install also prepares the machine for the pictures: the demo user Alex Example, whom the login
# screen proposes, and a kernel command line with boot=live for the installer (bind-mounted over
# /proc/cmdline while shoot.sh runs).
fake_cmdline=""
if [ "$install" = 1 ]; then
    apt-get install -y --no-install-recommends "$root_dir"/config/packages.chroot/*.deb
    id alex >/dev/null 2>&1 || useradd -m -c "Alex Example" -s /bin/bash alex
    mkdir -p /var/lib/amadeos-dm && echo alex > /var/lib/amadeos-dm/last-user
    fake_cmdline="$(mktemp)"
    echo "BOOT_IMAGE=/live/vmlinuz boot=live components quiet splash" > "$fake_cmdline"
    mount --bind "$fake_cmdline" /proc/cmdline || fake_cmdline=""
fi
command -v amadeos-session >/dev/null 2>&1 || { echo "shoot.sh: the amadeOS packages are not installed (--install)" >&2; exit 1; }

# As root, take the pictures as the demo user, so that the screen lock and the title bars show alex
# and /home/alex; the pictures go through a directory alex can write to.
if [ "$(id -u)" = 0 ] && id alex >/dev/null 2>&1; then
    out="$(mktemp -d)"
    chown alex "$out"
    rc=0
    runuser -u alex -- env SHOOT_HOME=/home/alex SHOOT_OUT="$out" "${BASH_SOURCE[0]}" "${scenes[@]}" || rc=$?
    cp -r "$out/." "$images_dir/"
    rm -rf "$out"
    [ -z "$fake_cmdline" ] || { umount /proc/cmdline; rm -f "$fake_cmdline"; }
    exit "$rc"
fi
images_dir="${SHOOT_OUT:-$images_dir}"

# A fresh demo home for every run, so earlier runs leave nothing behind: a temporary one, or the home
# of the demo user that --install created.
work="$(mktemp -d)"
export HOME="${SHOOT_HOME:-$work/home}"
mkdir -p "$HOME"
[ -z "${SHOOT_HOME:-}" ] || find "$HOME" -mindepth 1 -delete
cp -r "$here/home/." "$HOME/"
export XDG_CONFIG_HOME="$HOME/.config" XDG_CACHE_HOME="$HOME/.cache" XDG_DATA_HOME="$HOME/.local/share"
export USER="$(id -un)"
# A UTF-8 locale, so that titles such as "amade-pad — amadeOS Text Editor" come out right; the language
# of the desktop is the one of ~/.config/amadeos/locale.conf in the demo home.
if locale -a 2>/dev/null | grep -qi '^en_GB.utf-\?8$'; then export LANG=en_GB.UTF-8; else export LANG=C.UTF-8; fi

# The launchers find the Java 25 runtime of amadeOS themselves; a JAVA_HOME of the build machine (an
# older Java) would get in the way.
unset JAVA_HOME

export DISPLAY=:77
Xvfb "$DISPLAY" -screen 0 1280x800x24 -nolisten tcp >/dev/null 2>&1 &
xvfb_pid=$!
cleanup() {
    pkill -P $$ 2>/dev/null || true
    kill "$xvfb_pid" 2>/dev/null || true
    [ -z "$fake_cmdline" ] || { umount /proc/cmdline; rm -f "$fake_cmdline"; }
    sleep 1
    rm -rf "$work"
}
trap cleanup EXIT
for _ in $(seq 1 50); do xdpyinfo >/dev/null 2>&1 && break; sleep 0.1; done

# shellcheck source=scenes.sh
. "$here/scenes.sh"

# Helpers for the scenes ----------------------------------------------------------------------------

# Waits until a window whose name matches $1 is mapped (at most $2 seconds, default 30).
wait_window() {
    local i
    for i in $(seq 1 $((${2:-30} * 4))); do
        xdotool search --onlyvisible --name "$1" >/dev/null 2>&1 && return 0
        sleep 0.25
    done
    echo "shoot.sh: no window '$1' appeared" >&2
    return 1
}

# Starts a program in the background, its output into the work directory.
start() {
    "$@" >>"$work/programs.log" 2>&1 &
}

# Closes every window of the programs started by the scenes (not the panel and the window manager).
close_programs() {
    local pid children
    for pid in $(jobs -p); do
        [ "$pid" = "$session_pid" ] || [ "$pid" = "$xvfb_pid" ] && continue
        # The launcher first, so that a wrapper such as amadeos-lock does not start its program again.
        children="$(pgrep -P "$pid" || true)"
        kill "$pid" 2>/dev/null || true
        [ -z "$children" ] || kill $children 2>/dev/null || true
    done
    sleep 1
}

# shot CHAPTER NAME [GEOMETRY]: saves the screen, or the part WxH+X+Y of it, as JPEG.
shot() {
    mkdir -p "$images_dir/$1"
    sleep "${SHOT_DELAY:-1.5}"
    import -window root "$work/shot.png"
    if [ -n "${3:-}" ]; then
        convert "$work/shot.png" -crop "$3" +repage -quality 90 "$images_dir/$1/$2.jpg"
    else
        convert "$work/shot.png" -quality 90 "$images_dir/$1/$2.jpg"
    fi
    echo "  $1/$2.jpg"
}

click() { xdotool mousemove "$1" "$2" click "${3:-1}"; sleep 0.5; }
key() { xdotool key "$@"; sleep 0.5; }
type_text() { xdotool type --delay 30 "$1"; sleep 0.3; }

# The session ---------------------------------------------------------------------------------------

session_pid=""
start_session() {
    amadeos-session "$DISPLAY" >>"$work/session.log" 2>&1 &
    session_pid=$!
    wait_window "Front Panel|CDE|amadeOS" 60 || true
    sleep 6
}

[ ${#scenes[@]} -gt 0 ] || scenes=("${ALL_SCENES[@]}")
for scene in "${scenes[@]}"; do
    echo "scene $scene"
    "scene_$scene"
done
