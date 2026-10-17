# amadeOS

**Digital Sovereignty starts on your desktop.**

amadeOS is an open source Linux distribution with a timeless, classic desktop. Its source code is
freely available under the European Union Public Licence, so anyone can inspect, change and share it.

[![Build](https://github.com/datazuul/amadeos/actions/workflows/build.yml/badge.svg)](https://github.com/datazuul/amadeos/actions/workflows/build.yml)
[![License: EUPL-1.2](https://img.shields.io/badge/license-EUPL--1.2-003399)](LICENSE)
[![Java 25](https://img.shields.io/badge/Java-25-ED8B00?logo=openjdk&logoColor=white)](https://openjdk.org/projects/jdk/25/)
[![Debian 13 trixie](https://img.shields.io/badge/Debian-13%20trixie-A81D33?logo=debian&logoColor=white)](https://www.debian.org/releases/trixie/)
[![Display: X11](https://img.shields.io/badge/display-Xorg%2FX11-555555)](https://www.x.org/)
[![Boot: BIOS + UEFI](https://img.shields.io/badge/boot-BIOS%20%2B%20UEFI-555555)](#getting-started)
[![Status: pre-release](https://img.shields.io/badge/status-pre--release-yellow)](ROADMAP.md)
[![Last commit](https://img.shields.io/github/last-commit/datazuul/amadeos)](https://github.com/datazuul/amadeos/commits/main)

---

amadeOS is a free, Java-powered European desktop operating system: a bootable x86-64 live image
based on Debian, with a desktop written in Java. Display manager, window manager, front panel and
settings tools are Swing applications on Xorg, styled after the Common Desktop Environment (CDE).

## Why amadeOS

- **Open source, all the way up.** Everything from the login screen to the text editor is free
  software under the [EUPL-1.2](LICENSE), a licence published by the European Commission and legally
  valid in all official EU languages.
- **Built on proven foundations.** Debian Stable as the base, Linux as the kernel, Xorg/X11 as the
  display stack. amadeOS adds a desktop, not a new platform you have to trust.
- **Understandable.** The desktop is plain Java and Swing. One codebase, one language, readable by
  anyone who wants to know what their system does.
- **Open standards instead of lock-in.** Applications are ordinary Debian packages with Freedesktop
  `.desktop` entries; the window manager speaks ICCCM and EWMH, so non-Java X11 programs work too.
- **A desktop that stays.** The classic CDE look and workflow: a front panel, workspaces and
  Motif-style windows, without fashion-driven redesigns.

## Status

amadeOS is in active development and has not had a release yet. Milestones M0 to M11 are complete
(bootable image, Java window manager, desktop shell, display manager, application discovery,
virtual workspaces); M12, release hardening, is in progress. Progress is tracked in
[`ROADMAP.md`](ROADMAP.md), the design decisions and rejected alternatives in
[`CONCEPT.md`](CONCEPT.md).

## Architecture

```mermaid
flowchart TD
    subgraph System ["System (systemd, root)"]
        DM["Display manager & login greeter<br>amadeos-dm.service, PAM"]
        Xorg["Xorg server (:0)"]
    end
    subgraph Session ["User session"]
        WM["Window manager<br>reparenting, Motif/CDE frames"]
        Panel["Front panel<br>clock, workspaces, drawers"]
        Tools["Style Manager, screen saver,<br>input settings"]
        Apps["Applications<br>amade-pad, amade-mail, any X11 client"]
    end
    DM -->|starts| Xorg
    DM -->|authenticates & starts| Session
    WM -->|frames| Apps
    Panel -->|EWMH| WM
    Panel -->|launches| Apps
```

All Java components live in one JAR (`/opt/amadeos/amadeos.jar`); the first argument selects the
component, e.g. `dm`, `wm`, `panel`, `style` (Style Manager), `screen` (screen saver), `input`
(apply keyboard, mouse and bell settings) or `lock`.

## What is in the image

| Component | Description |
|---|---|
| **Base** | Debian *trixie* (minimal), Linux, Xorg/X11, OpenJDK 25, BIOS and UEFI boot. |
| **Display manager** | `amadeos-dm.service` starts Xorg on VT 7 and shows the Java login greeter, which authenticates through PAM (`/etc/pam.d/amadeos-dm`) and starts the session in the language chosen there. |
| **Time zone** | Chosen in the login greeter (*Time Zone*, the zones of `zone1970.tab`, preselected with the system's current zone). The display manager runs as root and, once the password is accepted, points `/etc/localtime` at the zone and writes `/etc/timezone` before the session starts. The live image boots with `Europe/Berlin` (`timezone=` on the kernel command line) and `systemd-timesyncd` sets the clock from the network. |
| **Window manager** | A floating, reparenting X11 window manager in Java (Xlib via JNA) with Motif/CDE-style frames, interactive move and resize, minimize to desktop icons, four virtual workspaces, a desktop root menu and the EWMH/ICCCM hints that panels and toolkits rely on (`_NET_CLIENT_LIST`, `_NET_ACTIVE_WINDOW`, `_NET_CURRENT_DESKTOP`, `_NET_WM_STRUT_PARTIAL`, `WM_DELETE_WINDOW`, ...). |
| **Front panel** | A CDE-style dock with clock, calendar, workspace switcher and drawers that list installed applications from their `.desktop` files. |
| **Logs** | One log per application in `~/.cache/amadeos/logs` (`firefox-esr.log`, `amade-files.log`, ...), written by the panel when it starts a program, next to `session.log` and `wm.log` from `amadeos-session`. *Session Diagnostics & Logs* in the Tools drawer shows one of them at a time, chosen from a list, with the display manager's logs from `/var/log` and the system journal of this boot (the live user is in `systemd-journal`); *Follow* reloads every two seconds. |
| **Language** | English, Deutsch, Français, Español, Italiano. Chosen in the login greeter (*Language*, preselected with the user's last choice) for the whole session, or with the language button under the lock in the front panel. Both write `~/.config/amadeos/locale.conf`; applications built on amade-commons start in that language, the panel and terminals follow at the next login (`LANG`). An application's own *Settings* can override it. |
| **Style Manager** (`style`) | The controls of CDE's dtstyle. Color (palette and icon theme), Backdrop, Keyboard, Mouse, Beep and Screen work; Font, Window and Startup are shown but not yet available. |
| **Icons** | The NsCDE icon theme is the default (package `nscde-icon-theme`, built by `scripts/package-nscde-icons.sh`, included in the image automatically). Any other installed Freedesktop icon theme can be chosen in the Style Manager. |
| **Backdrops** | The original CDE pattern backdrops (Pebbles, Concave, BrickWall, Toronto, ...) come as the separate package `amadeos-backdrops-cde` (built by `scripts/package-cde-backdrops.sh`, installed to `/usr/share/amadeos/backdrops/cde`) and take their shades from the chosen backdrop color like in dtstyle. Own `.pm`/`.bm` files (XPM/XBM) are found in `~/.dt/backdrops` and `~/.config/amadeos/backdrops`, pictures (PNG/JPEG) as well. |
| **Input settings** (`input`) | Keyboard repeat and click, mouse handedness, double-click time and acceleration, and the bell; stored in `~/.config/amadeos/input.conf` and applied with `xset`, `xmodmap` and `xrdb` at login (`/etc/amadeos/autostart.d/10-amadeos-input`) and on Apply. |
| **Screen saver** (`screen`) | CDE's dtscreen: started through `/etc/amadeos/autostart.d/50-amadeos-screen`, uses the X server's idle counter (MIT-SCREEN-SAVER, `libxss1`), shows a saver module (Qix, Swarm, Starfield, Floating Logo, Blank) and locks the screen after the configured time. Settings in `~/.config/amadeos/screen.conf`. |
| **Web browser** | Firefox ESR from Debian (Gecko, MPL-2.0, security updates through `debian-security`) in the five desktop languages. `/usr/share/firefox-esr/distribution/policies.json` turns off telemetry, studies, Pocket and sponsored content, makes Ecosia the default search engine and installs uBlock Origin; `/etc/xdg/mimeapps.list` makes Firefox the default for web links and HTML files. |
| **Applications** | Separate Debian packages; `.deb` files placed in `config/packages.chroot/` are installed into the image. |

## The amadeOS family

| Repository | Purpose |
|---|---|
| [amadeos](https://github.com/datazuul/amadeos) | This repository: live image, display manager, window manager, front panel and settings tools |
| [amade-commons](https://github.com/datazuul/amade-commons) | Shared library: desktop themes, colors and Motif styling, application scaffold |
| [amade-pad](https://github.com/datazuul/amade-pad) | Text editor |
| [amade-mail](https://github.com/datazuul/amade-mail) | Mail client (IMAP/SMTP) in the style of CDE's dtmail |

The Style Manager writes the chosen theme to `~/.config/amadeos/theme.conf`; applications follow
that file and switch together with window frames and front panel. Gradle takes amade-commons from
JitPack, or builds a checkout in `../amade-commons` instead.

## Getting started

Requirements: Java 25, and for the image `live-build`, `sudo` and optionally QEMU or Xephyr.
[`CONTRIBUTING.md`](CONTRIBUTING.md) lists the packages per distribution.

```bash
git clone https://github.com/datazuul/amadeos.git
cd amadeos

./gradlew test         # unit and X11 integration tests (the latter need Xvfb)
./run-xephyr.sh        # window manager and panel in a nested X server, no ISO needed
./run-greeter.sh       # login greeter in a nested X server (mock PAM)
./build.sh             # build artifacts/amadeos-amd64.iso (uses sudo for live-build)
./run-qemu.sh          # boot the ISO in QEMU
```

The live user is `amadeos` with the password `amadeos`.

### Building the complete distribution

`build.sh` puts into the image whatever application packages are already in
`config/packages.chroot/`. To build everything from the current `main` branches instead, clone
amade-commons and the applications next to this repository (`../amade-commons`, `../amade-pad`,
`../amade-mail`, ...) and run:

```bash
./buildDistribution.sh
```

It pulls `main` of amadeos, amade-commons and every `../amade-*` application that has an
`installToAmadeOs` Gradle task, builds amade-commons and the applications against that checkout
(with tests), copies their `.deb` packages into `config/packages.chroot/` and builds
`artifacts/amadeos-amd64.iso`. It stops before pulling if a repository has uncommitted changes.
Options: `--no-pull` (build the checkouts as they are), `--skip-tests`, `--quick` (repack the
previous image, see `AMADEOS_QUICK`) and `--apps "amade-pad amade-mail"` (only these
applications).

### Writing the image to a USB stick

The ISO is a hybrid image for BIOS and UEFI: it is written to the stick as it is, byte for byte,
without copying it onto a file system on the stick. **This erases everything on the stick.**

On Linux:

```bash
sha256sum -c artifacts/amadeos-amd64.iso.sha256   # check the image
lsblk -d -o NAME,SIZE,MODEL,TRAN                   # find the stick (TRAN usb), e.g. sdb
sudo umount /dev/sdX?*                             # unmount its partitions if auto-mounted
sudo dd if=artifacts/amadeos-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync oflag=direct
```

Replace `sdX` with the stick's whole device (`/dev/sdb`, not the partition `/dev/sdb1`), and
check the name twice: `dd` overwrites the device it is given without asking. When `dd` has
returned, the stick can be removed. GNOME Disks (*Restore Disk Image*) does the same with a
graphical interface. On Windows, use [Rufus](https://rufus.ie/) in *DD image* mode, on macOS
`sudo dd if=amadeos-amd64.iso of=/dev/rdiskN bs=4m` after `diskutil unmountDisk /dev/diskN`.

To boot from the stick, choose it in the computer's boot menu (often F12, F11, F9 or Esc right
after switching on). With Secure Boot enabled, UEFI firmware refuses the unsigned boot loader;
switch Secure Boot off or use legacy BIOS boot.

## Contributing

Contributions are welcome: small, testable changes to the desktop, compatibility tests on real
hardware, new applications as Debian packages, documentation. [`CONTRIBUTING.md`](CONTRIBUTING.md)
describes the development setup, how to package applications for amadeOS and the Git workflow.
Bugs and ideas go to the [issue tracker](https://github.com/datazuul/amadeos/issues).

## License

amadeOS is free software, licensed under the
[European Union Public Licence v. 1.2](LICENSE) (EUPL-1.2, SPDX identifier `EUPL-1.2`). The EUPL is
published by the European Commission and is legally valid in all official languages of the EU;
translations are available at
[interoperable-europe.ec.europa.eu](https://interoperable-europe.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

Copyright © 2026 datazuul.com and contributors.

The live image is an aggregation of Debian packages and separately packaged applications; each of
them keeps its own licence (see `/usr/share/doc/<package>/copyright` on the running system). In
particular, the NsCDE icon theme built by `scripts/package-nscde-icons.sh` stays under the GPL-3.0
as a separate package, and the CDE backdrops packaged by `scripts/package-cde-backdrops.sh`
(`amadeos-backdrops-cde`, fetched from the CDE sources at build time) stay under the LGPL-2+. The
screenshots in `docs/` show third-party software and are not covered by this repository's licence.
