#!/bin/sh
# DazeOS X11 Launcher with Session & Power Lifecycle Management (Milestone M6)

if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
    while true; do
        ACTION_FILE="${HOME:-/tmp}/.dazeos-session-action"
        rm -f "$ACTION_FILE"

        if grep -qs quiet /proc/cmdline; then
            startx > /dev/null 2>&1
        else
            startx
        fi

        ACTION="$(cat "$ACTION_FILE" 2>/dev/null || echo "")"
        rm -f "$ACTION_FILE"

        case "$ACTION" in
            poweroff)
                echo "[DazeOS] Shutting down system..."
                systemctl poweroff 2>/dev/null || sudo poweroff 2>/dev/null || poweroff
                break
                ;;
            reboot)
                echo "[DazeOS] Rebooting system..."
                systemctl reboot 2>/dev/null || sudo reboot 2>/dev/null || reboot
                break
                ;;
            shell)
                echo ""
                echo "=========================================================="
                echo " DazeOS X11 Desktop Session Ended."
                echo " You are now in the interactive console shell (tty1)."
                echo " - Type 'startx' to launch the desktop session again."
                echo " - Type 'sudo poweroff' to shut down."
                echo " - Type 'sudo reboot' to reboot."
                echo "=========================================================="
                echo ""
                break
                ;;
            restart|*)
                echo "[DazeOS] Desktop session ended. Restarting session..."
                sleep 0.5
                ;;
        esac
    done
fi
