# 55. The Session

The **session** is everything that runs between your login and your logout: the window manager, the Front Panel, the programs that start with them, and the programs you open. This chapter shows how to start your own programs at login, how to change the session's settings and how another panel takes the Front Panel's place.

## What happens at login

After the greeter has checked your password (chapter 20), the session starts in this order:

1. The **window manager**, which draws the window frames. If it ever crashes, the session starts it again, and your windows stay open.
2. The **autostart scripts**, all at once: the keyboard and mouse settings, the password window of chapter 50, the clipboard manager, the screen saver, and your own.
3. The **Front Panel**. The session lasts as long as the panel: when you log out with *EXIT* (chapter 26), the panel ends, and the session with it.

## Starting programs at login

Programs that should start at every login go into your own autostart folder, `~/.config/amadeos/autostart.d`. Each entry there is a small script, and every script that is executable runs at login, in the background.

For example, to open the Mailer at every login:

```sh
mkdir -p ~/.config/amadeos/autostart.d
cat > ~/.config/amadeos/autostart.d/60-mailer <<'END'
#!/bin/sh
sleep 5
exec amade-mail
END
chmod +x ~/.config/amadeos/autostart.d/60-mailer
```

The `sleep 5` lets the panel appear first. To stop the program from starting, delete the script or remove its execute permission (`chmod -x`).

!!! tip
    The scripts run in the order of their names, but they do not wait for each other. A two-digit number at the front, as in `60-mailer`, keeps them sorted.

!!! planned "Planned"
    The *Startup* page of Settings (chapter 35) will manage the autostart and whether the session opens the windows of your last session again.

## The session's settings

The session reads its settings from `/etc/amadeos/session.conf`, for all users, and then from `~/.config/amadeos/session.conf`, for you alone, which wins. Copy the lines you want to change:

| Setting | Default | What it is |
|---|---|---|
| `WM_COMMAND` | `/usr/bin/amadeos-wm` | The window manager. |
| `WM_ENABLED` | `true` | `false` starts the session without a window manager. |
| `WM_AUTO_RESTART` | `true` | Start the window manager again if it crashes. |
| `WM_LOG_FILE` | `~/.cache/amadeos/logs/wm.log` | Where the window manager logs. |
| `SESSION_LOG_FILE` | `~/.cache/amadeos/logs/session.log` | Where the session logs. |
| `AUTOSTART_APP` | `panel` | The program the session lasts for: `panel` is the installed panel, or any command. |

A changed setting counts from the next login.

!!! warning
    With a wrong `WM_COMMAND` or `AUTOSTART_APP` the desktop may not start. Then log in with the *Failsafe Terminal* session of the greeter and delete `~/.config/amadeos/session.conf` (chapter 57).

## Another panel

The Front Panel is one package, `amadeos-panel-cde`. A different panel, a taskbar for example, can take its place: any package that provides the virtual package `amadeos-panel` can be installed instead. With several panels installed, the administrator chooses which one starts:

```sh
sudo update-alternatives --config amadeos-panel
```

A single user can choose another one for themselves with `AUTOSTART_APP` in their `session.conf`.

!!! planned "Planned"
    Today the CDE Front Panel is the only panel of amadeOS. The way to replace it is there so that other desktops can follow without changing the rest of the system.

??? hood "Under the hood"
    The session is the shell script `/usr/bin/amadeos-session`; the greeter starts it as you, and it is also registered as `x-session-manager`, so `startx` starts the desktop too. The system's autostart scripts are in `/etc/amadeos/autostart.d`: `10-amadeos-input`, `30-amadeos-polkit-agent`, `40-amadeos-clipboard` and `50-amadeos-screen`. The language chosen at login is written to `~/.config/amadeos/locale.conf`.
