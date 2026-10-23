# 56. Settings and Files Reference

amadeOS keeps its settings in plain text files, which you can read, copy and back up like any other file. This chapter lists where they are.

## Your settings

Your settings are in your home folder, in folders whose names start with a dot and which the File Manager hides unless you show hidden files.

| Folder | What is in it |
|---|---|
| `~/.config/amadeos/` | The settings of the desktop and the amade applications. |
| `~/.local/share/amadeos/` | Data the programs keep for you: calendars, game scores. |
| `~/.cache/amadeos/` | Logs and other things the programs can make again. Safe to delete. |

### The desktop

| File in `~/.config/amadeos/` | Written by | Chapter |
|---|---|---|
| `theme.conf`, `icon_theme.conf` | Settings: Color | 31 |
| `font.conf` | Settings: Font | 35 |
| `wallpaper.conf` | Settings: Backdrop | 32 |
| `input.conf` | Settings: Keyboard, Mouse, Beep | 33 |
| `screen.conf` | Settings: Screen | 34 |
| `window.conf` | Settings: Window | 35 |
| `clipboard.conf` | Settings: Clipboard | 36 |
| `workspaces.conf` | Settings: Workspaces, and renaming in the Front Panel | 24, 37 |
| `panel.conf` | Settings: Front Panel, and the clock's right-click menu | 37 |
| `startup.conf` | Settings: Startup (the desktop services switched off) | 35 |
| `settings.conf` | Settings: the sidebar or the compact view | 30 |
| `locale.conf` | The greeter and the language button | 25 |
| `session.conf` | You, by hand | 55 |
| `autostart.d/` | You, by hand | 55 |

### The applications

The amade applications keep their settings in a folder of their own below `~/.config/amadeos/` (the Mailer in `~/.config/amadeos/mail`, for example) and their data below `~/.local/share/amadeos/` (the scores of the games in `~/.local/share/amadeos/games/<game>/`). Passwords, such as those of mail accounts, are not in these files but in your login keyring (chapter 58).

The programs that start at login are desktop entries in `~/.config/autostart/` (Settings: Startup, chapter 35); your own login scripts are in `~/.config/amadeos/autostart.d/` (chapter 55).

Firefox keeps its profile in `~/.mozilla/firefox/`, LibreOffice in `~/.config/libreoffice/`.

!!! tip
    To take your desktop to another computer, copy `~/.config/amadeos/` and `~/.local/share/amadeos/` to the same place in your home folder there.

!!! tip
    To reset the look of the desktop, log out, delete the file of the control in question (or all of `~/.config/amadeos/`), and log in again. Everything starts with the defaults.

## Settings of the system

The settings for all users belong to the administrator and are in `/etc`.

| File | What it is |
|---|---|
| `/etc/amadeos/session.conf` | The session's defaults (chapter 55). |
| `/etc/amadeos/autostart.d/` | The programs that start for every user at login (chapter 55). |
| `/etc/default/keyboard` | The keyboard layout of the greeter and the console. |
| `/etc/timezone`, `/etc/localtime` | The time zone, set in the greeter. |
| `/etc/hostname`, `/etc/hosts` | The computer's name. |
| `/etc/NetworkManager/system-connections/` | Network connections and WLAN passwords (chapter 54). |
| `/etc/cups/` | Printers (chapter 54). |
| `/etc/apt/sources.list.d/` | Where software and updates come from (chapters 51 and 52). |
| `/etc/apt/apt.conf.d/50amadeos-unattended` | Automatic security updates, written by Software (chapter 52). |
| `/etc/pam.d/amadeos-dm`, `/etc/pam.d/amadeos-lock` | How the greeter and the screen lock check passwords. |
| `/etc/polkit-1/rules.d/` | Your own permission rules (chapter 50). |

Files that came with a package and that you changed are kept when the package is updated; if the new version changes them as well, apt asks which to keep.

## Logs

| File | What it records | Chapter |
|---|---|---|
| `~/.cache/amadeos/logs/session.log` | The session | 57 |
| `~/.cache/amadeos/logs/wm.log` | The window manager | 57 |
| `~/.cache/amadeos/logs/<program>.log` | Each program started from the Front Panel | 57 |
| `/var/log/amadeos-session-runner.log` | The greeter's start of the session | 57 |
| `/var/log/amadeos-xorg.log` | The X server | 57 |
| `/var/log/amadeos-packages.log` | Software installed, updated and removed | 52 |
| The system journal (`journalctl`) | Everything else | 57 |
