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

# The drawers show only the programs of the amadeOS image, not whatever else the build machine has
# installed: XDG_DATA_DIRS points at a directory with the desktop entries of the image's packages (the
# package list and config/packages.chroot) and the system's icons and MIME data.
xdg="$work/xdg"
mkdir -p "$xdg/applications"
for dir in icons mime pixmaps; do ln -s "/usr/share/$dir" "$xdg/$dir"; done
{
    grep -hv '^\s*#' "$root_dir"/config/package-lists/*.list.chroot 2>/dev/null | tr -s ' \t' '\n'
    for deb in "$root_dir"/config/packages.chroot/*.deb; do dpkg-deb -f "$deb" Package; done
} | sort -u | while read -r package; do
    [ -n "$package" ] || continue
    dpkg-query -L "$package" 2>/dev/null | grep '^/usr/share/applications/.*\.desktop$' || true
done | while read -r entry; do ln -sf "$entry" "$xdg/applications/"; done
export XDG_DATA_DIRS="$xdg"

# The launchers find the Java 25 runtime of amadeOS themselves; a JAVA_HOME of the build machine (an
# older Java) would get in the way.
unset JAVA_HOME

export DISPLAY=:77
Xvfb "$DISPLAY" -screen 0 1280x800x24 -nolisten tcp >/dev/null 2>&1 &
xvfb_pid=$!
cleanup() {
    pkill -P $$ 2>/dev/null || true
    kill "$xvfb_pid" 2>/dev/null || true
    [ -z "${dbus_pid:-}" ] || kill "$dbus_pid" 2>/dev/null || true
    [ -z "$fake_cmdline" ] || { umount /proc/cmdline; rm -f "$fake_cmdline"; }
    sleep 1
    rm -rf "$work"
}
trap cleanup EXIT
for _ in $(seq 1 50); do xdpyinfo >/dev/null 2>&1 && break; sleep 0.1; done

# A session bus and a login keyring with a few passwords, unlocked as PAM unlocks it at login, so that
# Settings > Passwords has a keyring to show (gnome-keyring and libsecret-tools; skipped without them).
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && command -v dbus-launch >/dev/null 2>&1; then
    eval "$(dbus-launch --sh-syntax)"
    dbus_pid="$DBUS_SESSION_BUS_PID"
fi
if command -v gnome-keyring-daemon >/dev/null 2>&1 && command -v secret-tool >/dev/null 2>&1; then
    printf 'alex' | gnome-keyring-daemon --unlock --components=secrets >/dev/null 2>&1 || true
    for service in mail.example.org web.example.org printer; do
        printf 'demo' | secret-tool store --label="$service" service "$service" user alex 2>/dev/null || true
    done
fi

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
    # Without the Java options of the machine that takes the pictures, which the logs would show
    env -u JAVA_TOOL_OPTIONS amadeos-session "$DISPLAY" >>"$work/session.log" 2>&1 &
    session_pid=$!
    wait_window "Front Panel|CDE|amadeOS" 60 || true
    sleep 6
}

[ ${#scenes[@]} -gt 0 ] || scenes=("${ALL_SCENES[@]}")
for scene in "${scenes[@]}"; do
    echo "scene $scene"
    "scene_$scene"
done
