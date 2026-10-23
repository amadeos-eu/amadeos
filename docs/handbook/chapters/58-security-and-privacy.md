# 58. Security and Privacy

amadeOS is built so that your computer works for you and tells nobody else what you do with it. This chapter collects what amadeOS does for that, and what you can do yourself.

## What amadeOS does not do

- **No account.** You log in with a local user and password (chapter 53); no online account is needed, and none is linked.
- **No telemetry.** The desktop and the amade applications send no usage data, no crash reports and no diagnostics anywhere. Firefox is set up the same way (chapter 48).
- **No advertising and no tracking.** No program shows advertisements or recommends products.
- **No updates behind your back.** Updates are offered and installed when you say so; automatic security updates only when you turn them on (chapter 52).

What the computer does contact by itself: the Debian mirror once a day to look for updates, and a public time server to set the clock. Printers and scanners are looked for in your own network.

## Your passwords

| Password | Where it is kept |
|---|---|
| Your login password | Only as a one-way hash in `/etc/shadow` (chapter 50). |
| Passwords of programs, such as mail accounts | In your **login keyring**, encrypted with your login password. |
| WLAN passwords | In the network settings of the system, readable only by administrators (chapter 54). |
| Passwords saved in Firefox | In Firefox's own store; protect it with a *Primary Password* in Firefox's settings. |

The login keyring is opened when you log in, with the same password, so programs can use their passwords without asking you again. It is closed when you log out. *Settings → Passwords* (chapter 38) locks it, unlocks it and changes its password. In a terminal, `secret-tool search --all service amade-mail` shows what the Mailer has stored.

!!! planned "Planned"
    A keyring service of amadeOS's own, written in Java like the rest of the desktop, with a password window in the style of the desktop, to take GNOME Keyring's place (ROADMAP milestone M12).

## The clipboard

The clipboard history (chapter 36) keeps the last things you copied, **in memory only**: it is gone when you log out and never written to the disk. Copies that a password manager marks as secret are never recorded. **Clear History** on the *Clipboard* page of Settings, or *Clear All* in the history, forgets everything at once; *Pause recording* stops it for a while.

## Lock the screen

Lock the screen when you leave the computer: ++super+l++, or the lock in the Front Panel (chapter 26). The screen saver locks it by itself after a time that you set on the *Screen* page of Settings (chapter 34).

## Updates

Security updates close holes that others could use. Install them when the updates cell turns red, or let amadeOS install them by itself (chapter 52).

## The network

amadeOS runs only a few services that the network can reach: the discovery of printers and other devices in the local network (Avahi), and the print system, which listens only on the computer itself. No remote login is installed.

There is no firewall turned on, because nothing else listens. For a laptop that you use in public networks, you can add one:

```sh
sudo apt install ufw
sudo ufw enable
```

`ufw` blocks everything that comes in unasked and lets everything out; the computer still finds printers once you allow them, for example `sudo ufw allow from 192.168.1.0/24`.

## Your files

Your home folder is readable only by you and the administrators. On the disk, however, files are not encrypted: whoever takes the disk out of the computer can read it.

!!! planned "Planned"
    Disk encryption in the installer (ROADMAP milestone M14), so that a lost or stolen laptop gives nothing away.

Until then, keep sensitive files on an encrypted USB stick, and **make backups**: copy your home folder to an external disk regularly, with the File Manager (chapter 41) or in a terminal:

```sh
rsync -a --delete ~/ /media/$USER/BACKUP/home/
```

(Replace `BACKUP` with the name of your disk; `--delete` also removes files on the backup that you deleted at home.)

!!! sovereignty "Your data"
    Everything in this chapter comes down to one rule of amadeOS: your data stays on your computer unless you send it somewhere. Chapter 1 explains why.

??? hood "Under the hood"
    The login keyring is GNOME Keyring's `gnome-keyring-daemon`, which serves the freedesktop.org Secret Service; `pam_gnome_keyring` in `/etc/pam.d/amadeos-dm` starts and unlocks it at login. Its files are in `~/.local/share/keyrings/`. `ss -tulpn` lists the ports on which the computer listens.
