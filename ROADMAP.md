# amadeOS roadmap

What is open and planned comes first, then a timeline of what has been achieved, newest first. A feature counts as verified only with evidence from the QEMU live image or real hardware; merged work without that evidence is listed under *Waiting for a test*. The detailed notes of each milestone up to 2026-10-24 are in the git history (ROADMAP.md at commit `b58c372`).

Status date: 2026-10-24

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
        PowerDlg["Session & Power Dialog<br>Logout, Shell, Poweroff, Reboot"]
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
| M16 amadeOS package repository | Planned, proposal waiting for a decision |

## Open and planned

### Waiting for a test

Merged and installed by `buildDistribution.sh`, but so far only checked under Xvfb or in containers:

- Settings with all its pages (Display, Font, Window, Workspaces, Front Panel, Passwords, Updates, Language, Startup), per-workspace names and backdrops, the seasonal themes.
- Front Panel status slot: network, sound (`pactl`, not yet against PipeWire), battery (not yet on a laptop), updates; the busy light above EXIT.
- Alt+Tab switcher, clipboard manager, bell through the sound card (Xvfb ignores `xset b`), gnome-keyring unlocked at login.
- Software (M15): the end-to-end test in QEMU — first start loads the package lists, the polkit password window appears, a package gets installed, an update goes through the panel cell.
- Installer (M14): the UEFI path (`run-qemu.sh --uefi`) and installing next to Windows, then the Zephyrus laptop (UEFI, NVMe, Secure Boot with the signed shim).
- Not tested at all yet: real hardware, graphics acceleration, firmware, WLAN, audio, suspend/resume, several monitors, USB boot.

### M12 — Compatibility, security and release hardening

- A documented release process: release manifest (image version, package inputs, checksum, test results), reproducible-build checks, image signing, artifact provenance, rollback and recovery.
- Pin and document the supported Java baseline.
- Test fonts, HiDPI scaling, keyboard layouts, focus and modality, and representative Swing/AWT applications.
- An own Secret Service daemon in Java (D-Bus `org.freedesktop.secrets`, unlocked by the login password, Motif prompt) to replace gnome-keyring and its GTK prompter.
- The WLAN password is passed to `nmcli` as an argument and briefly visible in the process list; a D-Bus client would avoid that.
- Decide whether JNA/libX11 stays or FFM or JNI/XCB is justified; reassess Wayland only after that.
- Display: maximizing per monitor and the panel on the primary monitor (several monitors are one large desktop today).

**Exit criteria:** a documented release process exists, supported hardware and software boundaries are explicit, and another contributor can rebuild and evaluate the image.

### M13 — Application suite

- Terminal: an own terminal emulator, or a decision to keep xterm.
- Network settings: an own dialog instead of `nmtui` in xterm.
- amade-mail: test Gmail OAuth2 and decide whether to ship a datazuul OAuth client; IMAP IDLE with new-mail state in the in-tray; autoconfig (Thunderbird ISPDB, DNS SRV).
- amade-contacts: meeting attendees in the Calendar, CardDAV.
- amade-imageviewer: map tiles not yet tried against the live tile server.

**Exit criteria:** each Front Panel slot opens an amadeOS application instead of an `xterm` command, and all applications follow the Settings theme. Only the terminal and the network settings are left.

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

**Goal:** amadeOS and the amade applications arrive as updates, not only inside the ISO. Every package is still version 0.1.0, all are `Architecture: all`, and no repository has a release workflow yet.

- Proposal of 2026-10-23, waiting for a decision: a stateless publish script (`apt-ftparchive`, `appstreamcli compose` for DEP-11 so Software shows the amade applications, gpg signing subkey), a release workflow per repository that attaches the `.deb` to a GitHub release on a version tag, and a package `amadeos-archive-keyring` with the key and `/etc/apt/sources.list.d/amadeos.sources`.
- Hosting is open: GitHub Pages, or `apt.amadeos.eu` on the server behind www.amadeos.eu (its folder is reserved in the amadeos.eu repository).
- Then: `postinst` scripts for what image hooks set up today, and `build-image.sh` takes packages from the repository instead of `config/packages.chroot/`.

**Exit criteria:** publishing a tag of an amade application makes the update appear on an installed system within the check interval.

## Timeline

Newest first. Numbers without a repository name are pull requests in this repository; amadeos-system is abbreviated *system*, amade-commons *commons*.

### 2026-10-24

- **Website [www.amadeos.eu](https://www.amadeos.eu/) online:** static pages from [`amadeos.eu`](https://github.com/datazuul/amadeos.eu), deployed to an own server by an Ansible playbook (nginx, Let's Encrypt).
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
- **New applications:** [`amade-calculator`](https://github.com/datazuul/amade-calculator) (Basic, Scientific, Programmer; #57), [`amade-imageviewer`](https://github.com/datazuul/amade-imageviewer) (#59), [`amade-pdfviewer`](https://github.com/datazuul/amade-pdfviewer), default for PDF (#61), [`amade-contacts`](https://github.com/datazuul/amade-contacts) with address completion in the Mailer and birthdays in the Calendar (#63, #65), [`amade-books`](https://github.com/datazuul/amade-books), an EPUB and CBZ reader (#64) with 15 public-domain books from [`amadeos-sample-books`](https://github.com/datazuul/amadeos-sample-books) (#71, #72).
- File Manager tree view as the default (amade-files #7, #60).
- Hover Cab, the 15th game (#58).
- LibreOffice Calc, Impress, Draw and Math next to Writer (#69).
- **The User's Handbook is complete** (Parts VI and VII, appendices A to F; #49 to #52, #68).

### 2026-10-22

- **Clipboard manager** (system #34): history in memory only, Ctrl+Alt+V, Tools drawer.
- [`amade-screenshot`](https://github.com/datazuul/amade-screenshot) (#48).
- Application Developer's Handbook in amade-commons: chapters on every application, the commons library and the desktop modules; AppStream metainfo and screenshots for every amade application and game.

### 2026-10-21

- **M15 built:** helper and library (system #18), updates cell (system #19), Software with Updates and catalog tabs and AppStream (system #21 to #23), package lists at first start (system #24), own Motif polkit agent (system #26).
- **Games drawer** with all games installed by default (system #20, #41).
- **User's Handbook** Parts I to V (#42, #45, #46), offline package `amadeos-handbook`, opened from the Help slot.
- gnome-keyring as the Secret Service, unlocked at login (system #28); LibreOffice Writer in the image (#43).

### 2026-10-18 to 2026-10-20

- **Installation to disk (M14):** [`amadeos-installer`](https://github.com/datazuul/amadeos-installer) with a five-language assistant and the `amadeos-install` script; a whole-disk BIOS installation in QEMU boots into the desktop and the new user logs in (#36).
- Java package root `eu.amadeos`, system packages renamed `amadeos-*`, AGENTS.md, plan for M15 and M16 (#37 to #39).
- Game Developer's Handbook and games on [`amade-game-engine`](https://github.com/datazuul/amade-game-engine), from Paddle to Town, with Part IV "The Engine Manual".

### 2026-10-16 to 2026-10-17

- The desktop moves to [`amadeos-system`](https://github.com/datazuul/amadeos-system) as one Gradle multi-project with one Debian package per module (#31 to #34), with Print Manager, System Information and Session Diagnostics & Logs; amade-calendar joins the family (#35).
- Network: NetworkManager, WLAN firmware and the network cell in the Front Panel's new status slot; the bell plays through the sound card.

### 2026-10-13 to 2026-10-14

- **Shared library [`amade-commons`](https://github.com/datazuul/amade-commons)** (#13): themes, Motif look-and-feel, XDG directories, keyring and start-up for the desktop and all applications.
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
- [amadeOS User's Handbook](https://datazuul.github.io/amadeos/) — the system from the user's side
- [www.amadeos.eu](https://www.amadeos.eu/) — project website
