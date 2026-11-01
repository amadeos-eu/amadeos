# The scenes of shoot.sh: one function scene_<name> per group of screenshots, run in the order of
# ALL_SCENES. The coordinates fit the 1280x800 screen of shoot.sh with the Front Panel of amadeos-panel-cde
# (thirteen slots); when the panel changes, adjust the PANEL_* values below.
# shellcheck shell=bash

ALL_SCENES=(greeter installer desktop panel drawers menu windows workspaces style lock apps games admin develop polkit)

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
    # Alt+Tab, held: the switcher with the pictures of the three windows
    xdotool keydown alt key Tab
    sleep 1
    shot 23 alt-tab
    xdotool key Escape keyup alt
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
    # Renaming, as in CDE: a second click on the current workspace's button, a new name, Return; an
    # empty name gives the demo account back its "Two"
    click "${PANEL_WS_TWO[@]}"
    key ctrl+a
    type_text "Letters"
    shot 24 workspace-rename "$PANEL_GEOMETRY"
    key Return
    click "${PANEL_WS_TWO[@]}"
    key ctrl+a BackSpace Return
    click "${PANEL_WS_ONE[@]}"
    close_programs
}

scene_style() {
    [ -n "$session_pid" ] || start_session
    # The Settings opened at each control: amadeos-settings <control> selects its page in the sidebar
    local control name chapter
    for control in color:30 color:31 font:35 backdrop:32 keyboard:33 mouse:33 sound:33 beep:33 screen:34 window:35 startup:35 clipboard:36 \
            workspaces:37 panel:37 network:38 proxy:38 bluetooth:38 printers:38 passwords:38 updates:38 language:38 datetime:38 applications:40; do
        IFS=: read -r name chapter <<<"$control"
        # The Screen page with the settings of a new user; the demo home keeps the saver off
        [ "$name" != screen ] || { cp "$HOME/.config/amadeos/screen.conf" "$work/screen.conf"
            printf 'saver.enabled=true\nsaver.minutes=10\nsaver.module=qix\nlock.enabled=true\nlock.minutes=15\n' \
                >"$HOME/.config/amadeos/screen.conf"; }
        start amadeos-settings "$name"
        wait_window "^Settings$" 30 || continue
        sleep 2
        if [ "$chapter" = 30 ]; then
            shot_window 30 settings "^Settings$"
            # A search: Ctrl+F, a word, the list of matching settings
            key ctrl+f
            type_text lock
            sleep 1
            shot_window 30 settings-search "^Settings$"
        else
            shot_window "$chapter" "settings-$name" "^Settings$"
        fi
        close_programs
        [ "$name" != screen ] || cp "$work/screen.conf" "$HOME/.config/amadeos/screen.conf"
    done
    # The compact view: the CDE row of controls, and one control in a window of its own
    cp "$HOME/.config/amadeos/settings.conf" "$work/settings.conf" 2>/dev/null || rm -f "$work/settings.conf"
    printf 'view=compact\n' >"$HOME/.config/amadeos/settings.conf"
    start amadeos-settings
    if wait_window "^Settings$" 30; then
        sleep 2
        shot_window 30 settings-compact "^Settings$"
    fi
    close_programs
    start amadeos-settings mouse
    if wait_window "Settings - Mouse" 30; then
        sleep 1
        shot_window 30 settings-compact-mouse "Settings - Mouse"
    fi
    close_programs
    if [ -f "$work/settings.conf" ]; then cp "$work/settings.conf" "$HOME/.config/amadeos/settings.conf"
    else rm -f "$HOME/.config/amadeos/settings.conf"; fi
}

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

# app_shot CHAPTER NAME WINDOW X Y W H COMMAND...: starts the program, puts its window at X Y with the
# size W x H (no size when W is 0), takes it with its frame and closes it again.
app_shot() {
    local chapter="$1" name="$2" window="$3" x="$4" y="$5" w="$6" h="$7"
    shift 7
    start "$@"
    wait_window "$window" 40 || { close_programs; return 0; }
    sleep 3
    if [ "$w" = 0 ]; then place "$window" "$x" "$y"; else place "$window" "$x" "$y" "$w" "$h"; fi
    sleep 2
    shot_window "$chapter" "$name" "$window"
    close_programs
}

# calculator_shot NAME SETTINGS KEYS...: the Calculator with these settings (lines of calculator.properties,
# separated by \n), after typing the keys; at its own size, since its window fits its keys.
calculator_shot() {
    local name="$1" settings="$2"
    shift 2
    mkdir -p "$HOME/.config/amadeos/calculator"
    printf "$settings\n" > "$HOME/.config/amadeos/calculator/calculator.properties"
    start amade-calculator
    wait_window "^Calculator$" 40 || { close_programs; return 0; }
    sleep 2
    place "^Calculator$" 140 60
    xdotool search --onlyvisible --name "^Calculator$" windowactivate --sync 2>/dev/null || true
    local keys
    for keys in "$@"; do type_text "$keys"; done
    xdotool mousemove 5 5
    sleep 1
    shot_window 48 "$name" "^Calculator$"
    close_programs
}

# files_shots: the File Manager in its tree view with two files selected, their context menu, the
# note while dragging them onto a folder of the tree (Escape cancels, nothing moves), the path bar as
# text with Tab completion, and the two-panel view. Clicks are relative to the window of 1000 x 640.
files_shots() {
    rm -f "$HOME/.config/amadeos/files/files.conf"
    start amade-files "$HOME/Documents"
    wait_window "File Manager" 40 || { close_programs; return 0; }
    sleep 3
    place "File Manager" 140 60 1000 640
    sleep 2
    local id i
    id="$(xdotool search --onlyvisible --name "File Manager" | head -n 1)"
    xdotool windowactivate --sync "$id" 2>/dev/null || true
    # The two lines of ~/Documents, the second one with Ctrl
    xdotool mousemove --window "$id" 500 93 click 1; sleep 0.3
    xdotool keydown ctrl mousemove --window "$id" 500 111 click 1 keyup ctrl
    xdotool mousemove --window "$id" 900 500; sleep 0.5
    shot_window 41 file-manager "File Manager"
    xdotool mousemove --window "$id" 470 111 click 3; sleep 0.8
    shot_window 41 file-manager-context-menu "File Manager"
    key Escape
    # Dragging both onto Downloads in the tree: rows of the tree are 20 pixels high, Home first
    xdotool mousemove --window "$id" 470 93 mousedown 1; sleep 0.2
    for i in $(seq 1 25); do xdotool mousemove --window "$id" $((470 - i * 15)) $((93 + i)); sleep 0.03; done
    xdotool mousemove --window "$id" 96 116; sleep 0.4
    xdotool mousemove --window "$id" 98 115; sleep 0.5
    shot_window 41 file-manager-drag "File Manager"
    key Escape
    xdotool mouseup 1; sleep 0.5
    # The path bar as text: Ctrl+L, a path, Tab completes the folder name
    key ctrl+l ctrl+a
    type_text "~/Pic"
    key Tab
    shot_window 41 file-manager-path-bar "File Manager"
    key Escape
    key ctrl+2
    shot_window 41 file-manager-two-panels "File Manager"
    # Back to the tree view, the default, for the next run
    key ctrl+1
    close_programs
}

# imageviewer_shots: the Image Viewer with its sidebar, and the same picture on the whole screen with
# the control bar that a mouse move brings up.
imageviewer_shots() {
    mkdir -p "$HOME/.config/amadeos/imageviewer"
    printf 'sidebar=true\nfilm-strip=true\n' > "$HOME/.config/amadeos/imageviewer/imageviewer.properties"
    start amade-imageviewer "$HOME/Pictures/mountain-lake.png"
    wait_window "Image Viewer" 40 || { close_programs; return 0; }
    sleep 3
    place "Image Viewer" 140 60 1000 640
    sleep 2
    shot_window 47 image-viewer "Image Viewer"
    xdotool search --onlyvisible --name "Image Viewer" windowactivate --sync 2>/dev/null || true
    key F11
    sleep 2
    xdotool mousemove 400 300 mousemove 420 320
    shot 47 image-viewer-full-screen
    key Escape
    close_programs
}

# imageeditor_shots: the Image Editor with the crop frame at 16:9, then the colour sliders with the
# comparison of original and adjusted picture, then painting, an arrow and a text on layers.
imageeditor_shots() {
    start amade-imageeditor "$HOME/Pictures/mountain-lake.png"
    wait_window "Image Editor" 40 || { close_programs; return 0; }
    sleep 3
    place "Image Editor" 140 60 1000 640
    sleep 1
    xdotool search --onlyvisible --name "Image Editor" windowactivate --sync 2>/dev/null || true
    key ctrl+k
    sleep 2
    shot_window 47 image-editor "Image Editor"
    key Escape
    key ctrl+j
    sleep 1
    key space
    sleep 2
    shot_window 47 image-editor-adjust "Image Editor"
    key Escape
    # Painting: a ring with the brush, an arrow with Shapes, then a text being typed. The tool keys work
    # while the picture has the keyboard, so the canvas is clicked first with the Pick tool (I); D then
    # sets black and white again.
    local id
    id=$(xdotool search --onlyvisible --name "Image Editor" | head -1)
    key i
    xdotool mousemove --window "$id" 400 400 click 1; sleep 0.3
    key d
    key b
    xdotool mousemove --window "$id" 300 470 mousedown 1; sleep 0.1
    for i in $(seq 0 40); do
        a=$(awk -v i="$i" 'BEGIN { printf "%d %d", 260 + 110 * cos(i * 6.4 / 40), 470 + 50 * sin(i * 6.4 / 40) }')
        xdotool mousemove --window "$id" $a; sleep 0.02
    done
    xdotool mouseup 1; sleep 0.5
    key u
    xdotool mousemove --window "$id" 520 200 mousedown 1; sleep 0.1
    for i in $(seq 1 10); do xdotool mousemove --window "$id" $((520 - i * 18)) $((200 + i * 22)); sleep 0.03; done
    xdotool mouseup 1; sleep 0.3
    key Return
    key t
    xdotool mousemove --window "$id" 560 160 click 1; sleep 0.5
    type_text "Our boat!"
    sleep 1
    shot_window 47 image-editor-paint "Image Editor"
    close_programs
}

# pdfviewer_shots: the PDF Viewer with the page thumbnails and a search, then two pages at a time with
# the table of contents. The document is Part I of this handbook, made with reportlab
# (home/Documents/amadeos-handbook-part-1.pdf).
pdfviewer_shots() {
    local settings="$HOME/.config/amadeos/pdfviewer/pdfviewer.properties"
    local document="$HOME/Documents/amadeos-handbook-part-1.pdf"
    mkdir -p "$(dirname "$settings")"
    printf 'view=continuous\nzoom=fit-width\nsidebar=true\nsidebar-tab=pages\n' > "$settings"
    start amade-pdfviewer "$document"
    wait_window "PDF Viewer" 40 || { close_programs; return 0; }
    sleep 3
    place "PDF Viewer" 140 60 1000 640
    xdotool search --onlyvisible --name "PDF Viewer" windowactivate --sync 2>/dev/null || true
    key ctrl+f; type_text "desktop"; key Return; sleep 2; key Return
    xdotool mousemove 5 5
    sleep 2
    shot_window 48 pdf-viewer "PDF Viewer"
    close_programs
    printf 'view=two-pages\nzoom=fit-page\nsidebar=true\nsidebar-tab=contents\n' > "$settings"
    start amade-pdfviewer "$document"
    wait_window "PDF Viewer" 40 || { close_programs; return 0; }
    sleep 3
    place "PDF Viewer" 140 60 1000 640
    xdotool search --onlyvisible --name "PDF Viewer" windowactivate --sync 2>/dev/null || true
    key ctrl+g; type_text "3"; key Return
    xdotool mousemove 5 5
    sleep 3
    shot_window 48 pdf-viewer-contents "PDF Viewer"
    close_programs
}

# Contacts with the demo address book of the home: the window with Anna Berger's card, her card in the
# editor, and the import of a table from Google Contacts.
contacts_shots() {
    start amade-contacts
    wait_window "Contacts" 40 || { close_programs; return 0; }
    sleep 3
    place "Contacts" 140 60 1000 640
    sleep 2
    shot_window 45 contacts "Contacts"
    click 480 220; key ctrl+e
    if wait_window "Edit Contact" 15; then
        sleep 2; shot_window 45 contacts-editor "Edit Contact"; key Escape
    fi
    key ctrl+i
    if wait_window "Import Contacts" 15; then
        sleep 1; type_text "$HOME/Documents/google-contacts.csv"; key Return
        if wait_window "Import google-contacts.csv" 15; then
            sleep 2; shot_window 45 contacts-import "Import google-contacts.csv"; key Escape
        fi
    fi
    close_programs
}

# The applications of Part V, each in a window of 1000 x 640 where the program lets itself be sized.
scene_apps() {
    [ -n "$session_pid" ] || start_session
    # The Application Manager: the icon of the Tools slot
    click "$PANEL_TOOLS_X" 765
    if wait_window "Application Manager" 15; then
        sleep 2; shot_window 40 application-manager "Application Manager"; key Escape
        xdotool search --onlyvisible --name "Application Manager" windowclose 2>/dev/null || true
    fi
    mkdir -p "$HOME/Pictures"
    cp "$root_dir/config/includes.chroot/usr/share/backgrounds/amadeos/mountain-lake.png" "$HOME/Pictures/"
    files_shots
    app_shot 42 text-editor "Text Editor" 140 60 1000 640 amade-pad "$HOME/Documents/letter-to-the-club.txt"
    app_shot 43 writepad "Writepad|WritePad" 140 30 1000 680 amade-writepad --sample
    app_shot 44 mailer "Mailer" 140 60 1000 640 amade-mail
    app_shot 45 calendar "Calendar" 140 60 1000 640 amade-calendar
    contacts_shots
    app_shot 46 audio-station "Audio Station" 60 20 0 0 amade-audio
    # Without a GPU some builds of libmpv refuse the video output and say so in a message; Enter
    # closes it, and the window shows what it shows before a video is opened.
    start amade-video
    if wait_window "Video Player" 40; then
        sleep 3; key Return; place "^Video Player$" 140 60 900 600
        shot_window 46 video-player "^Video Player$"
    fi
    close_programs
    imageviewer_shots
    imageeditor_shots
    app_shot 47 image-scan "Image Scan" 140 60 1000 640 amade-imagescan "$HOME/Pictures/mountain-lake.png"
    app_shot 47 fractals "Fractals" 140 60 1000 640 amade-fractals
    calculator_shot calculator "mode=basic\npaper-tape=true" "1234.5*3=" "19.99+4.5+7.25=" "200+10%=" "1/3*3=" "1234567.89*12"
    calculator_shot calculator-scientific "mode=scientific\npaper-tape=false" "(2+3)^2*p="
    calculator_shot calculator-programmer "mode=programmer\npaper-tape=false\nradix=hex\nword-size=64\nsigned=true" "ff00|2a="
    pdfviewer_shots
    app_shot 48 documentation-viewer "Documentation Viewer|/usr/share/doc" 140 60 1000 640 amade-web
}

# The title screen of every game, where the computer plays.
scene_games() {
    [ -n "$session_pid" ] || start_session
    local game
    for game in mines solitaire paddle bricks snake rocks swarm maze blast jump towers sands colony town; do
        app_shot 49 "$game" "$(tr '[:lower:]' '[:upper:]' <<<"${game:0:1}")${game:1}" 140 60 0 0 "amade-$game-game"
    done
}

# The system programs of Part VI and the clipboard history of Part IV.
scene_admin() {
    [ -n "$session_pid" ] || start_session
    # Software, with the programs of amadeOS found by the search field
    start amadeos-software
    if wait_window "^Software$" 60; then
        sleep 20; place "^Software$" 100 40 1080 660; sleep 2
        frame_geometry "^Software$" && click $((FX + 200)) $((FY + 67)) && type_text "amade" && sleep 3
        shot_window 51 software "^Software$"
    fi
    close_programs
    app_shot 57 session-logs "Session Diagnostics" 100 40 1080 660 amadeos-logviewer
    # The Print Manager with a job held in the queue, when CUPS runs and knows a printer
    if command -v lp >/dev/null && lpstat -d >/dev/null 2>&1; then
        lp -H hold -t "letter-to-the-club.txt" "$HOME/Documents/letter-to-the-club.txt" >/dev/null || true
    fi
    app_shot 54 print-manager "Print Manager" 140 60 1000 600 amadeos-print
    ! command -v cancel >/dev/null || cancel -a 2>/dev/null || true
    # The clipboard history after three copies in the Text Editor
    start amade-pad "$HOME/Documents/letter-to-the-club.txt"
    if wait_window "Text Editor" 40; then
        sleep 3
        local line
        for line in 0 2 5; do
            key ctrl+Home
            [ "$line" = 0 ] || key --repeat "$line" Down
            key Home shift+End ctrl+c
            sleep 1
        done
        key ctrl+alt+v
        if wait_window "Clipboard History" 15; then
            sleep 1; place "Clipboard History" 340 120; sleep 1
            shot_window 36 clipboard-history "Clipboard History"
            key Escape
        fi
    fi
    close_programs
}

# Chapter 63: a desktop entry of one's own in the Tools drawer.
scene_develop() {
    # The panel watches the folder only if it exists when the panel starts
    mkdir -p "$HOME/.local/share/applications"
    [ -n "$session_pid" ] || start_session
    cat >"$HOME/.local/share/applications/backup.desktop" <<END
[Desktop Entry]
Type=Application
Name=Back Up Documents
Comment=Copies the documents folder to the backup disk
Exec=/bin/true
Icon=drive-harddisk
Terminal=true
Categories=System;
END
    sleep 4
    open_drawer "$PANEL_TOOLS_X"; shot 63 drawer-tools-own-entry 620x380+580+420; close_drawer "$PANEL_TOOLS_X"
    rm -f "$HOME/.local/share/applications/backup.desktop"
}

# Chapter 50: the password window. A machine without a login session (the virtual screen of shoot.sh) has
# no agent for the session, so an agent of its own serves the shell that runs pkexec (pkexec asks for its
# parent process). It needs polkitd and, without an active session, a local rule that asks for the
# password instead of refusing, such as
# /etc/polkit-1/rules.d/90-shoot.rules: if (action.id === "eu.amadeos.packages.manage") AUTH_ADMIN_KEEP.
scene_polkit() {
    [ -n "$session_pid" ] || start_session
    pgrep -x polkitd >/dev/null || { echo "shoot.sh: polkitd is not running, no password window" >&2; return 0; }
    start sh -c '/usr/libexec/amadeos-session polkit-agent --process $$ & sleep 6; pkexec /usr/libexec/amadeos-packages check'
    if wait_window "Authentication Required" 40; then
        sleep 2; place "Authentication Required" 380 200; sleep 1
        shot_window 50 password-window "Authentication Required"
    fi
    close_programs
}
