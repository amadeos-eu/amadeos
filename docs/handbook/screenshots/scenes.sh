# The scenes of shoot.sh: one function scene_<name> per group of screenshots, run in the order of
# ALL_SCENES. The coordinates fit the 1280x800 screen of shoot.sh with the Front Panel of amadeos-panel-cde
# (thirteen slots); when the panel changes, adjust the PANEL_* values below.
# shellcheck shell=bash

ALL_SCENES=(greeter installer desktop panel drawers menu windows workspaces style lock)

# Where things are on the screen: the drawer arrows of the Front Panel (x, at the height PANEL_ARROW_Y)
# and the workspace buttons.
PANEL_ARROW_Y=727
PANEL_FILES_X=250
PANEL_EDITOR_X=309
PANEL_MAIL_X=367
PANEL_GAMES_X=541
PANEL_PRINT_X=911
PANEL_TOOLS_X=969
PANEL_HELP_X=1027
PANEL_WS_ONE=(674 739)
PANEL_WS_TWO=(777 739)
PANEL_GEOMETRY=1116x86+82+714

# The login greeter alone, before the session starts (amadeos-dm greeter does not log in).
scene_greeter() {
    start java -jar "$(ls /opt/amadeos-dm/*.jar | head -n 1)" greeter
    wait_window "amadeOS|Login|Welcome" 30 || return 0
    sleep 3
    shot 20 login-screen
    click 640 400
    close_programs
}

# The installer with fake-install.sh instead of amadeos-install, so nothing is written to a disk.
scene_installer() {
    local fake page
    fake="$(dirname "${BASH_SOURCE[0]}")/../../../../amadeos-installer/scripts/fake-install.sh"
    [ -x "$fake" ] || { echo "shoot.sh: amadeos-installer is not checked out next to amadeos, no installer pictures" >&2; return 0; }
    start_session
    PATH="$(dirname "${BASH_SOURCE[0]}")/fake-bin:$PATH" AMADEOS_INSTALL_COMMAND="$fake" start amadeos-installer
    wait_window "Install amadeOS" 30 || return 0
    place "Install amadeOS" 140 40 1000 640
    for page in welcome keyboard timezone disk; do
        shot_window 14 "installer-$page" "Install amadeOS"
        key alt+n
    done
    # Full name (the user name follows it), password twice, computer name.
    type_text "Alex Example"
    key Tab Tab; type_text "correct horse"
    key Tab; type_text "correct horse"
    key Tab Tab ctrl+a; type_text "laptop-alex"
    shot_window 14 installer-user "Install amadeOS"
    key alt+n
    shot_window 14 installer-summary "Install amadeOS"
    close_programs
}

scene_desktop() {
    [ -n "$session_pid" ] || start_session
    shot 21 desktop
}

scene_panel() {
    [ -n "$session_pid" ] || start_session
    shot 22 front-panel "$PANEL_GEOMETRY"
}

# The drawers: Games for the tour, Text & Office, Tools and Help for the Front Panel chapter.
scene_drawers() {
    [ -n "$session_pid" ] || start_session
    open_drawer "$PANEL_GAMES_X"; shot 22 drawer-games 560x390+330+410; close_drawer "$PANEL_GAMES_X"
    open_drawer "$PANEL_EDITOR_X"; shot 22 drawer-office 520x300+150+500; close_drawer "$PANEL_EDITOR_X"
    open_drawer "$PANEL_TOOLS_X"; shot 22 drawer-tools 620x330+580+470; close_drawer "$PANEL_TOOLS_X"
    open_drawer "$PANEL_HELP_X"; shot 22 drawer-help 640x200+640+600; close_drawer "$PANEL_HELP_X"
}

open_drawer() { click "$1" "$PANEL_ARROW_Y"; sleep 1; }
close_drawer() { click "$1" "$PANEL_ARROW_Y"; sleep 0.5; }

# The Workspace Menu on the right mouse button.
scene_menu() {
    [ -n "$session_pid" ] || start_session
    click 300 120 3
    shot 24 workspace-menu 330x260+290+110
    key Escape
    click 900 300
}

# A few windows on the desktop: the Text Editor with a letter, the Calendar and the File Manager.
scene_windows() {
    [ -n "$session_pid" ] || start_session
    start amade-files "$HOME"
    wait_window "File Manager|Files" 30 || true
    place "File Manager|Files" 40 30 700 460
    start amade-calendar
    wait_window "Calendar" 30 || true
    place "Calendar" 520 60 720 520
    start amade-pad "$HOME/Documents/letter-to-the-club.txt"
    wait_window "Text Editor" 30 || true
    place "Text Editor" 230 250 640 400
    sleep 2
    shot 21 desktop-with-windows
    shot_window 23 window-frame "Text Editor"
    # The window menu of the button at the left end of the title bar
    if frame_geometry "Text Editor"; then
        click $((FX + 12)) $((FY + 12))
        shot 23 window-menu "360x220+$((FX > 20 ? FX - 20 : 0))+$((FY > 20 ? FY - 20 : 0))"
        key Escape
    fi
}

# place WINDOW X Y [WIDTH HEIGHT]: moves (and sizes) the window whose title matches WINDOW.
place() {
    local id
    id="$(xdotool search --onlyvisible --name "$1" | head -n 1)"
    [ -n "$id" ] || return 0
    [ -z "${4:-}" ] || xdotool windowsize "$id" "$4" "$5"
    xdotool windowmove "$id" "$2" "$3"
    sleep 0.5
}

scene_workspaces() {
    [ -n "$session_pid" ] || start_session
    click "${PANEL_WS_TWO[@]}"
    shot 24 workspace-two
    click "${PANEL_WS_ONE[@]}"
    close_programs
}

scene_style() {
    [ -n "$session_pid" ] || start_session
    start amadeos-style
    wait_window "Style Manager" 30 || return 0
    shot_window 30 style-manager "Style Manager"
    close_programs
    # Each control in a Style Manager of its own: the button, then the dialog "Style Manager - <name>"
    local control name index chapter
    for control in Color:0:31 Backdrop:2:32 Keyboard:3:33 Mouse:4:33 Beep:5:33 Screen:6:34; do
        IFS=: read -r name index chapter <<<"$control"
        # The Screen dialog with the settings of a new user; the demo home keeps the saver off
        [ "$name" != Screen ] || { cp "$HOME/.config/amadeos/screen.conf" "$work/screen.conf"
            printf 'saver.enabled=true\nsaver.minutes=10\nsaver.module=qix\nlock.enabled=true\nlock.minutes=15\n' \
                >"$HOME/.config/amadeos/screen.conf"; }
        start amadeos-style
        wait_window "^Style Manager$" 30 || continue
        frame_geometry "^Style Manager$" || continue
        click $((FX + STYLE_FIRST_X + index * STYLE_STEP_X)) $((FY + STYLE_BUTTON_Y))
        wait_window "Style Manager - $name" 15 || { close_programs; continue; }
        sleep 1
        shot_window "$chapter" "style-$(tr '[:upper:]' '[:lower:]' <<<"$name")" "Style Manager - $name"
        close_programs
        [ "$name" != Screen ] || cp "$work/screen.conf" "$HOME/.config/amadeos/screen.conf"
    done
}

# The row of controls in the Style Manager window, relative to its frame: the centre of the first
# button and the distance between two buttons.
STYLE_FIRST_X=56
STYLE_STEP_X=89
STYLE_BUTTON_Y=80

scene_lock() {
    [ -n "$session_pid" ] || start_session
    start amadeos-lock
    sleep 4
    shot 26 lock-screen
    close_programs
}

# frame_geometry WINDOW: sets FX, FY, FW and FH to the frame the window manager put around the window
# whose title matches WINDOW (the child of the root window that holds it); fails without such a window.
frame_geometry() {
    local id root parent info
    id="$(xdotool search --onlyvisible --name "$1" | head -n 1)"
    [ -n "$id" ] || { echo "shoot.sh: no window '$1'" >&2; return 1; }
    root="$(xwininfo -root | awk '/Window id:/ {print $4}')"
    while parent="$(xwininfo -tree -id "$id" | awk '/Parent window id:/ {print $4}')" && [ "$parent" != "$root" ]; do
        id="$parent"
    done
    info="$(xwininfo -id "$id")"
    FX="$(awk '/Absolute upper-left X:/ {print $4}' <<<"$info")"
    FY="$(awk '/Absolute upper-left Y:/ {print $4}' <<<"$info")"
    FW="$(awk '/Width:/ {print $2}' <<<"$info")"
    FH="$(awk '/Height:/ {print $2}' <<<"$info")"
}

# shot_window CHAPTER NAME WINDOW: the window whose title matches WINDOW, with its frame.
shot_window() {
    frame_geometry "$3" || return 0
    local x="$FX" y="$FY" w="$FW" h="$FH"
    [ "$x" -ge 0 ] || { w=$((w + x)); x=0; }
    [ "$y" -ge 0 ] || { h=$((h + y)); y=0; }
    shot "$1" "$2" "${w}x${h}+${x}+${y}"
}
