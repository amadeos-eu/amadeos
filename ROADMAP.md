# amadeOS roadmap

What is open and planned comes first, then a timeline of what has been achieved, newest first. A feature counts as verified only with evidence from the QEMU live image or real hardware; merged work without that evidence is listed under *Waiting for a test*. The detailed notes of each milestone up to 2026-10-24 are in the git history (ROADMAP.md at commit `b58c372`).

Status date: 2026-10-31

## Project direction

amadeOS is a free, European, Java-centred desktop system based on a minimal Debian x86-64 live image, with its own Java window manager, CDE-style Front Panel, display manager and applications. The architectural decisions and rejected alternatives are in [`CONCEPT.md`](CONCEPT.md).

```mermaid
flowchart TD
    subgraph System ["System Layer (systemd / root)"]
        DM["amadeOS Display Manager (Java + PAM)<br>amadeos-dm.service"]
        Xorg["Xorg Server (:0)"]
    end

    subgraph UserSession ["User Session Layer (user: amadeos)"]
        Session["amadeos-session (Supervisor)"]
        WM["amadeOS Window Manager (Java / JNA)<br>Reparenting, Decorations, Moving, Resizing"]
        Panel["amadeOS Desktop Panel (Java Swing)<br>Taskbar, App Menu, Clock, Tray"]
        Apps["Client Applications<br>Swing Apps, xterm, Editors"]
        PowerDlg["Session & Power Dialog<br>Suspend, Hibernate, Logout, Shell, Reboot, Poweroff"]
    end

    DM -->|Starts| Xorg
    DM -->|Authenticates & Spawns| Session
    Session -->|Supervises| WM
    Session -->|Launches| Panel
    Session -->|Launches| Apps
    Panel -->|Triggers| PowerDlg
    Panel -->|Manages via EWMH| WM
    WM -->|Frames & Decorates| Apps
```
## Milestones

| Milestone | Status |
|---|---|
| M0 Reproducible build | Done 2026-10-09 |
| M1 Boot (BIOS and UEFI) · M2 Session launcher · M3 Native X11 · M4 Floating WM · M5 Integrated session · M6 Power and lifecycle · M7 Reparenting and decorations · M8 Front Panel and themes · M9 Java display manager · M10 XDG discovery and .deb apps | Done 2026-10-10 |
| M11 Virtual workspaces and root menu | Done 2026-10-11 |
| M12 Compatibility, security and release hardening | In progress |
| M13 Application suite | In progress, nearly complete |
| M14 Installation to disk | In progress |
| M15 Updates and software management | Built, waiting for the QEMU test |
| M16 amadeOS package repository | stable suite online at apt.amadeos.eu, waiting for the QEMU test |

## Open and planned

### Waiting for a test

Merged and installed by `buildDistribution.sh`, but so far only checked under Xvfb or in containers:

- Settings with all its pages (Display, Font, Window, Workspaces, Front Panel, Passwords, Updates, Language, Startup), per-workspace names and backdrops, the seasonal themes.
- Front Panel status slot: network, sound (`pactl`, not yet against PipeWire), battery (not yet on a laptop), Bluetooth (not yet against BlueZ and a real adapter), updates, the second slot; the busy light above EXIT.
- Settings pages Network connections, Sound, Bluetooth and Printers: so far only with fake services under Xvfb; pairing, the sound card profiles and adding a printer need real devices.
- File Manager: USB sticks, memory cards and discs (mount, unmount, Safely Remove through `udisks2`) so far only with a fake drive list under Xvfb; needs a real stick in QEMU (`-device usb-storage`) or on hardware, also with the polkit rules of udisks for the active session. Extract and Compress are tested by unit tests.
- Power (Settings > Power, Suspend/Hibernate in EXIT, lid and power button): only unit tests and pictures under Xvfb; needs logind on a real laptop (lid, battery, suspend and resume, hibernate with swap).
- Horizon look: switching Classic and Horizon in a real session (the panel hand-over through `amadeos-session`), the rounded frames and the shaped dock on real graphics, the top bar's status cells on hardware.
- Alt+Tab switcher, clipboard manager, bell through the sound card (Xvfb ignores `xset b`), gnome-keyring unlocked at login.
- Software (M15): the end-to-end test in QEMU — first start loads the package lists, the polkit password window appears, a package gets installed, an update goes through the panel cell.
- Installer (M14): the UEFI path (`run-qemu.sh --uefi`) and installing next to Windows, then the Zephyrus laptop (UEFI, NVMe, Secure Boot with the signed shim).
- Not tested at all yet: real hardware, graphics acceleration, firmware, WLAN, audio, suspend/resume, several monitors, USB boot.

### Missing for daily use

Gap analysis of 2026-10-31: what a typical desktop has and amadeOS does not yet, in order of priority. Already under way at that date: Users and Groups in Settings, the image editor (merged), Backup & Sync step 2, a webcam application.

1. ~~USB sticks and external disks in the File Manager: `udisks2`, mount, Safely Remove.~~ Built 2026-10-31 (amade-files, see the timeline).
2. ~~Archives: open and create zip and tar files.~~ Built 2026-10-31 in the File Manager (Extract Here, Extract To…, Compress…; also reads 7z).
3. ~~Power: Suspend and Hibernate in the EXIT dialog, an action for the closed lid, a Settings page *Power* (screen off after, suspend after, on battery).~~ Built 2026-10-31 (amadeos-system: EXIT dialog, Settings > Power, lid and power button through logind; test on a real laptop open).
4. ~~Notifications: a daemon for `org.freedesktop.Notifications`, so Firefox, updates, Mailer and Calendar reminders can show pop-ups.~~ Built 2026-10-31 (pop-ups, history, bell, Do not disturb; see the timeline). Calendar, Mailer, Backup, TV and Webcam send through it (calendar #17, mail #15, backup #6, tv #10, webcam #2).
5. ~~Default applications: a Settings page for the program that opens web links, mail, PDFs, pictures, music and videos (`xdg-mime`).~~ Built 2026-10-31 (Settings > Default Applications, `~/.config/mimeapps.list`).
6. ~~Date and time: date and number formats (marked *Planned* on the Language page), network time on or off, setting the time by hand.~~ Built 2026-10-31 (Settings > Date and Time with the time zone, network time, the clock by hand and formats of a region of their own).
7. ~~Task manager / system monitor: processes, CPU and memory graphs, ending a program that hangs (System Information shows only a report).~~ Built 2026-10-31 (amadeos-system #61: `amadeos-taskmanager`, Ctrl+Shift+Esc and Ctrl+Alt+Del, the window manager marks windows that do not respond).
8. ~~Terminal: an own terminal or the decision to keep xterm (see M13).~~ Built 2026-11-01: `amade-terminal`, an own terminal with its own emulator (amade-terminal #1); xterm stays in the image for one release.
9. Disk tool: formatting a USB stick, partitions, disk health (SMART).
10. Settings pages *Keyboard shortcuts* and *Accessibility* (larger mouse pointer, high-contrast theme, sticky keys).
11. Firewall: a simple on/off switch with nftables.
12. More network settings: VPN, fixed addresses, hotspot (see M13).
13. A fully customizable Front Panel: add, remove and order its cells and controls in Settings > Front Panel (today the cells can only be switched on and off), with optional extra cells such as a CPU and memory graph that opens the Task Manager.

Nice to have: sticky notes, weather, a character map and font viewer, maps.

### M12 — Compatibility, security and release hardening

- Versions and releases (plan of 2026-10-24, tooling in [amadeos-ci](https://github.com/amadeos-eu/amadeos-ci)): Semantic Versioning from 1.0.0, computed from Conventional Commits; branches `develop` (builds `-dev.N`), `release` (`-pre.N`) and `main` (releases, tag `vX.Y.Z`, GitHub Release), moved forward by the Promote workflow. Open: the one-time branch setup (`setup-release-branches.sh` of amadeos-ci), the secret `PROMOTE_TOKEN`, then every repository's build workflow; amade-calculator is the pilot.
- A documented release process: release manifest (image version, package inputs, checksum, test results), reproducible-build checks, image signing, artifact provenance, rollback and recovery.
- Pin and document the supported Java baseline.
- Test fonts, HiDPI scaling, keyboard layouts, focus and modality, and representative Swing/AWT applications.
- An own Secret Service daemon in Java (D-Bus `org.freedesktop.secrets`, unlocked by the login password, Motif prompt) to replace gnome-keyring and its GTK prompter.
- The WLAN password is passed to `nmcli` as an argument and briefly visible in the process list; a D-Bus client would avoid that.
- Decide whether JNA/libX11 stays or FFM or JNI/XCB is justified; reassess Wayland only after that.
- Display: maximizing per monitor and the panel on the primary monitor (several monitors are one large desktop today).

**Exit criteria:** a documented release process exists, supported hardware and software boundaries are explicit, and another contributor can rebuild and evaluate the image.

### M13 — Application suite

- ~~Terminal: an own terminal emulator, or a decision to keep xterm.~~ Built 2026-11-01 (`amade-terminal`).
- Network settings: fixed addresses, VPN and a hotspot on the Settings Network page; connections, hidden WLANs and the proxy are there already, the rest is still `nmtui`.
- amade-mail: test Gmail OAuth2 and decide whether to ship a datazuul OAuth client; IMAP IDLE with new-mail state in the in-tray; autoconfig (Thunderbird ISPDB, DNS SRV).
- amade-contacts: meeting attendees in the Calendar, CardDAV.
- amade-imageviewer: map tiles not yet tried against the live tile server.

**Exit criteria:** each Front Panel slot opens an amadeOS application instead of an `xterm` command, and all applications follow the Settings theme. Only parts of the network settings are left.

### M14 — Installation to disk

- Shrinking a Windows partition from the installer, the hardware clock in local time next to Windows, disk encryption (LUKS), a separate home partition.
- The login greeter proposes the last user (or the first regular user) instead of `amadeos` on an installed system.
- Language, keyboard and time zone code shared by the installer and the greeter moves to amade-commons.
- Boot menu entry "Install" (`config/bootloaders/isolinux/install.cfg` is still a placeholder).

**Exit criteria:** an installation from the live image boots on a BIOS and a UEFI machine (QEMU and hardware) into the desktop with the chosen language, keyboard, time zone and user, without the live-only parts.

### M15 — Updates and software management

Built: the privileged helper `/usr/libexec/amadeos-packages` (apt through `pkexec`, polkit action `eu.amadeos.packages.manage`), the library module `packages`, the updates cell in the Front Panel, the program **Software** (Updates, Applications, Command line, Libraries; AppStream data) and an own Motif polkit agent. Open:

- The QEMU end-to-end test (see *Waiting for a test*).
- An `amadeos-desktop` meta package (today `buildDistribution.sh` installs every package of `repositories.list`).
- Offering `dpkg --configure -a` after an interrupted run; no snapshots or rollback yet. Flatpak and Snap are out of scope.

**Exit criteria:** on an installed system a pending Debian security update shows in the Front Panel and can be installed with a progress display, and a GUI and a command-line program can be found, installed and removed in Software; verified in QEMU.

### M16 — amadeOS package repository

**Goal:** amadeOS and the amade applications arrive as updates, not only inside the ISO. All packages are `Architecture: all`; versions and GitHub Releases come from the release branches (see M12). The suites follow the branches: `stable` from main, `testing` from release, `dev` from develop.

- **Online since 2026-10-27:** [apt.amadeos.eu](https://apt.amadeos.eu/), suite `stable` with the last three releases of every repository in `repositories.list`. A workflow in [`amadeos.eu`](https://github.com/amadeos-eu/amadeos.eu) collects the `.deb` files of the GitHub releases every 30 minutes, builds the indexes with `apt-ftparchive` and the AppStream data (DEP-11) with `appstreamcli compose`, signs with an ed25519 subkey (the primary key stays offline) and uploads by rsync to the server.
- The package `amadeos-archive-keyring` (key in `/usr/share/keyrings`, source in `/etc/apt/sources.list.d/amadeos.sources`) is in the image; `build-image.sh` downloads it from the repository. Systems installed from 1.0.0 install it once by hand (User's Handbook, chapter 52).
- Open: the suites `testing` (from release) and `dev` (from develop); `postinst` scripts for what image hooks set up today; `build-image.sh` taking the packages of a main build from the repository instead of `config/packages.chroot/`.

**Exit criteria:** publishing a tag of an amade application makes the update appear on an installed system within the check interval.

## Timeline

Newest first. Numbers without a repository name are pull requests in this repository; amadeos-system is abbreviated *system*, amade-commons *commons*.

### 2026-11-01

- Horizon look, step 2 (system #PR_SYS, commons #PR_COM): the **dock** at the bottom with the favourite and running programs (dot for running, ring for minimised; Keep in dock, Remove from dock, New window, Close), the program drawers, Downloads and Documents with their newest files, and the Trash; minimised windows go into the dock instead of onto the desktop; Settings > Desktop look sets the icon size and the dock's parts. User's Handbook chapter 29.
- Second desktop look **Horizon**, step 1 (system #63, commons #72): Settings > Desktop look switches Classic and Horizon live; Horizon has a top bar (`amadeos-panel-horizon`: system menu with all programs, program name, workspace dots, the Front Panel's status cells, clock), flat window frames with rounded corners and an accent line, Dark and Light schemes with six accent colours and two background pictures. The session swaps the panels without logging out. User's Handbook chapter 29. Planned next: dock with drawers, search, desktop widgets, flat applications, icon set, choice at the login screen.
- New application [`amade-terminal`](https://github.com/amadeos-eu/amade-terminal) (#1): the amadeOS terminal with its own xterm compatible emulator on a pseudo terminal (Java FFM, no native library); tabs, copy and paste (selection and middle click, Ctrl+Shift+C/V), a warning before pasting several lines, find in the scrollback, links, colour schemes. Registered as `x-terminal-emulator`; the Tools drawer, the desktop menu, `Terminal=true` programs and the new Ctrl+Alt+T start it (system #62); `bash-completion` in the image; User's Handbook chapter 42.

### 2026-10-31

- Task Manager (`amadeos-taskmanager`, system #61): the program windows with their load, Switch To and End Program; all processes as a tree with end, force end, pause, continue and priority; the last minute of processor, memory, network and disk as graphs. Ctrl+Shift+Esc and Ctrl+Alt+Del open it. The window manager pings windows (`_NET_WM_PING`); one that does not answer for 5 seconds gets *(Not Responding)* in its title and a dialog to wait or end it; User's Handbook chapter 59.
- Notifications (system #58, commons #66): `amadeos-session notifications` owns `org.freedesktop.Notifications`, so Firefox, `notify-send` and the amade programs show pop-ups in a corner above the Front Panel; a history of 7 days, a bell with the count of new ones in the status slot, Do not disturb (for a while, on a schedule, while a window is full screen) and Settings → Notifications with a choice per program; the Front Panel announces new updates. amade-commons has the `Notifications` API for the programs; `libnotify-bin` (`notify-send`) in the image; User's Handbook chapter 28.
- File Manager: network drives under *Network* in the folder tree: servers found through Avahi and WS-Discovery, Windows shares (SMB) with workgroup, user and password, NFS, WebDAV, SFTP and FTP through GVfs; the password can stay in the login keyring and shares can connect again at login; *File → Connect to Server…* (amade-files #14); `gvfs-backends`, `gvfs-fuse` and `wsdd` in the image; User's Handbook chapter 41.
- Power: Suspend and Hibernate in the EXIT window (Hibernate greyed out where logind cannot), Settings page *Power* (screen off and suspend after, on battery and plugged in; lid, power button, low battery warning and action; lock before sleeping), carried out by the session's screen daemon and the window manager through systemd-logind (system #57); User's Handbook chapters 26 and 34.
- New application [`amade-webcam`](https://github.com/amadeos-eu/amade-webcam) (#1): photos with self-timer and bursts, videos with sound (MP4, or WebM), time lapse, five looks, QR codes, the camera's picture controls; a camera light in the Front Panel's status slot while any program uses a camera (system #56); `v4l-utils` in the image; User's Handbook chapters 22 and 46.
- File Manager: USB sticks, memory cards, external disks and discs in the folder tree, mounted when plugged in or chosen, with Unmount and Safely Remove (Eject for discs) through `udisksctl`; archives open by extracting, with Extract Here, Extract To… and Compress… (zip, tar.gz, tar.xz; also reads 7z, tar.bz2, gz, bz2, xz) (amade-files #13); `udisks2` in the image; User's Handbook chapter 41.
- New application [`amade-imageeditor`](https://github.com/amadeos-eu/amade-imageeditor) (#1): crop with aspect ratios, straighten, turn, colours, resize, unlimited undo; saves JPEG, PNG, WebP, TIFF and BMP and keeps or drops camera data and location. The Image Viewer opens the shown picture in it (amade-imageviewer #9); `webp` in the image for WebP saving; User's Handbook chapter 47.

### 2026-10-29

- Rivet, the 18th game ([`amade-rivet-game`](https://github.com/amadeos-eu/amade-rivet-game) #1, game engine #40): a first-person shooter in 3D on the engine's new raycaster, with machines rendered from 3D models; Part VI of the Game Developer's Handbook.

### 2026-10-27

- **amadeOS package repository [apt.amadeos.eu](https://apt.amadeos.eu/)** (M16, amadeos.eu #4 and #5): signed suite `stable` with all 43 packages of 1.0.0 and AppStream data for Software, published every 30 minutes from the GitHub releases; the image brings `amadeos-archive-keyring`, so installed systems get the amade packages as updates.
- Settings: the Network page gets a *Connections* tab (wired, WLAN, hidden networks, details) next to the proxy, and new pages Sound (output, input, test tone, level meter, card profiles), Bluetooth (pairing with an own BlueZ agent) and Printers (driverless printers, default, paper size, two-sided) in a new group *Network and Devices*; a Bluetooth cell in the Front Panel, whose status slot opens a second slot for more than four cells; `bluez` and `libspa-0.2-bluetooth` in the image.

### 2026-10-26

- Artillery, the 17th game ([`amade-artillery-game`](https://github.com/amadeos-eu/amade-artillery-game) #1, game engine #38): tanks take turns on breakable ground, with wind and computer players at three levels.

### 2026-10-24

- **Versions and releases:** Semantic Versioning with Conventional Commits, release branches develop/release/main and the Promote workflow (new repository amadeos-ci); amade-calculator is the pilot.
- **Website [www.amadeos.eu](https://www.amadeos.eu/) online:** static pages from [`amadeos.eu`](https://github.com/amadeos-eu/amadeos.eu), deployed to an own server by an Ansible playbook (nginx, Let's Encrypt).
- **Front Panel sound cell** (system #46, #78): volume, mute, output and input device through `pactl`, mouse wheel and middle click.
- **Front Panel battery cell** (system #44, #76): only with a battery; fill colour, bolt on mains, percentage and remaining time.
- **Alt+Tab switcher** (system #45, #77): current workspace, most recently used first, small window previews without a compositor.
- **Halloween and Christmas themes** (system #42, #43, #73, #74): palettes with drawn backdrops.
- Pictures open in the Image Viewer by default (#75).
- Games no longer turn black in fullscreen (game engine #30, all games re-pinned); Blast ignores phantom gamepads (engine #28).

### 2026-10-23

- **Settings replaces the Style Manager** (system #37, #38, commons #21, #54): sidebar, search, compact CDE row; new pages Font, Window, Workspaces, Front Panel, Passwords, Updates, Language, Startup.
- **Display page** (system #39, #62): resolution, refresh rate, rotation, monitor arrangement through `xrandr`, with a 15-second "keep?" countdown; reapplied at login.
- **Workspace names and per-workspace backdrops** (system #36, #53).
- **Busy light above EXIT** (system #41, #70): program start, package installation, disk and network activity.
- **New applications:** [`amade-calculator`](https://github.com/amadeos-eu/amade-calculator) (Basic, Scientific, Programmer; #57), [`amade-imageviewer`](https://github.com/amadeos-eu/amade-imageviewer) (#59), [`amade-pdfviewer`](https://github.com/amadeos-eu/amade-pdfviewer), default for PDF (#61), [`amade-contacts`](https://github.com/amadeos-eu/amade-contacts) with address completion in the Mailer and birthdays in the Calendar (#63, #65), [`amade-books`](https://github.com/amadeos-eu/amade-books), an EPUB and CBZ reader (#64) with 15 public-domain books from [`amadeos-sample-books`](https://github.com/amadeos-eu/amadeos-sample-books) (#71, #72).
- File Manager tree view as the default (amade-files #7, #60).
- Hover Cab, the 15th game (#58).
- LibreOffice Calc, Impress, Draw and Math next to Writer (#69).
- **The User's Handbook is complete** (Parts VI and VII, appendices A to F; #49 to #52, #68).

### 2026-10-22

- **Clipboard manager** (system #34): history in memory only, Ctrl+Alt+V, Tools drawer.
- [`amade-screenshot`](https://github.com/amadeos-eu/amade-screenshot) (#48).
- Application Developer's Handbook in amade-commons: chapters on every application, the commons library and the desktop modules; AppStream metainfo and screenshots for every amade application and game.

### 2026-10-21

- **M15 built:** helper and library (system #18), updates cell (system #19), Software with Updates and catalog tabs and AppStream (system #21 to #23), package lists at first start (system #24), own Motif polkit agent (system #26).
- **Games drawer** with all games installed by default (system #20, #41).
- **User's Handbook** Parts I to V (#42, #45, #46), offline package `amadeos-handbook`, opened from the Help slot.
- gnome-keyring as the Secret Service, unlocked at login (system #28); LibreOffice Writer in the image (#43).

### 2026-10-18 to 2026-10-20

- **Installation to disk (M14):** [`amadeos-installer`](https://github.com/amadeos-eu/amadeos-installer) with a five-language assistant and the `amadeos-install` script; a whole-disk BIOS installation in QEMU boots into the desktop and the new user logs in (#36).
- Java package root `eu.amadeos`, system packages renamed `amadeos-*`, AGENTS.md, plan for M15 and M16 (#37 to #39).
- Game Developer's Handbook and games on [`amade-game-engine`](https://github.com/amadeos-eu/amade-game-engine), from Paddle to Town and the adventure The Seal of the Templars, with Part IV "The Engine Manual".

### 2026-10-16 to 2026-10-17

- The desktop moves to [`amadeos-system`](https://github.com/amadeos-eu/amadeos-system) as one Gradle multi-project with one Debian package per module (#31 to #34), with Print Manager, System Information and Session Diagnostics & Logs; amade-calendar joins the family (#35).
- Network: NetworkManager, WLAN firmware and the network cell in the Front Panel's new status slot; the bell plays through the sound card.

### 2026-10-13 to 2026-10-14

- **Shared library [`amade-commons`](https://github.com/amadeos-eu/amade-commons)** (#13): themes, Motif look-and-feel, XDG directories, keyring and start-up for the desktop and all applications.
- **Style Manager and screen saver** (#14): Color, Backdrop (the 26 original CDE backdrops as package `amadeos-backdrops-cde`), Screen, Keyboard, Mouse, Beep; screen saver daemon with lock.
- NsCDE as the default icon theme (#15); amade-pad and amade-mail in the image; the live image boots and works (boot-tested 2026-10-13).
- README "Digital Sovereignty starts on your desktop" (#16).

### 2026-10-12

- **Security and session hardening (M12, #1 to #12):** PAM-only login, X server with an MIT cookie, no world-writable input devices, console-only Xorg, Debian security archives; a root session worker owning the PAM session; screen lock as its own process with grabs; all Xlib calls on one thread; Gradle tests in CI; licensed under EUPL-1.2. Verified in the QEMU live ISO.

### 2026-10-11

- **M11:** four EWMH virtual workspaces switched from the Front Panel, the Motif root menu on the desktop, window stacking (Shuffle Up/Down).

### 2026-10-10

- **M1 to M10 in one day:** BIOS and UEFI boot verified in QEMU; session launcher with diagnostics; native X11 through JNA claiming the root window; floating WM with click-to-focus, ICCCM and EWMH; integrated session with watchdog; Session & Power dialog; reparenting WM with Motif decorations, move and 8-way resize; CDE Front Panel, desktop icon tiles, theme engine, NsCDE icon packaging, wallpaper on the X root window; Java display manager with PAM greeter (`amadeos-dm.service`); XDG application discovery filling the drawers, `.deb` drop-ins and amade-pad as the first independent application.

### 2026-10-09

- **M0:** a clean checkout builds a Debian 13 (Trixie) live ISO whose SHA-256 checksum verifies.

## Deferred by design

The following are intentionally outside the scope of current milestones:

- replacing the Linux kernel or Debian low-level userland
- a Wayland compositor (reassessed post-M12)
- compositing effects and 3D visual effects (drop shadows, blur, transparency)
- persistence of the live system (installation to disk is M14)
- Secure Boot signing of the live image (an installed system boots with Secure Boot through Debian's signed shim, see M14)
- broad hardware certification
- fully automatic package updates without the user's knowledge (checking and notifying, and installing security updates on request, are M15; the user stays in control)

*(Note: Server-side window decorations, reparenting WM, desktop panel/taskbar, display manager, XDG discovery, and virtual workspaces were originally deferred, but were implemented in milestones M6 through M11).*

## Working agreement for status updates

- A source file or build script is not evidence that its runtime behavior works.
- A successful ISO build is not evidence of BIOS, UEFI, hardware, or Swing compatibility.
- Every completed milestone should record the command, environment, artifact, and observed result.
- When a test is blocked, record the exact error and the next diagnostic action instead of marking the milestone complete.

## Related documentation

- [`README.md`](README.md) — project overview, components and how to build and run them
- [`CONCEPT.md`](CONCEPT.md) — architecture, decisions, alternatives, and risks
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — development environment, build commands, and validation procedure
- [amadeOS User's Handbook](https://docs.amadeos.eu/amadeos/) — the system from the user's side
- [www.amadeos.eu](https://www.amadeos.eu/) — project website
