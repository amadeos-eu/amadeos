# amadeOS

**amadeOS** — *Digital Autonomy, Zero Lock-in, Empowerment*.

amadeOS is a free, Java-powered European desktop operating system. It is a bootable
x86-64 live image based on Debian with a desktop written in Java: a display manager,
an X11 window manager and a CDE-style front panel, all on Xorg with Swing
applications.

The project is in active development; the milestones are tracked in
[`ROADMAP.md`](ROADMAP.md) and the design decisions in [`CONCEPT.md`](CONCEPT.md).

## What is in the image

- **Base:** Debian *trixie* (minimal), Linux, Xorg/X11, OpenJDK 21, BIOS and UEFI boot.
- **Display manager** (`amadeos-dm.service`): starts Xorg on VT 7 and shows the
  Java login greeter, which authenticates through PAM (`/etc/pam.d/amadeos-dm`).
- **Window manager:** a floating, reparenting X11 window manager in Java (Xlib via
  JNA) with Motif/CDE-style frames, interactive move and resize, minimize to desktop
  icons, four virtual workspaces, a desktop root menu and the EWMH/ICCCM hints that
  panels and toolkits rely on (`_NET_CLIENT_LIST`, `_NET_ACTIVE_WINDOW`,
  `_NET_CURRENT_DESKTOP`, `_NET_WM_STRUT_PARTIAL`, `WM_DELETE_WINDOW`, ...).
- **Icons:** the NsCDE icon theme is the default (package `nscde-icon-theme`, built by
  `scripts/package-nscde-icons.sh`, included in the image automatically); any other installed
  Freedesktop icon theme can be chosen in the Style Manager.
- **Style Manager** (`style`): the controls of CDE's dtstyle; Color (palette and icon theme),
  Backdrop, Keyboard, Mouse, Beep and Screen work, Font, Window and Startup are shown but not yet
  available.
- **Backdrops:** the original CDE pattern backdrops (Pebbles, Concave, BrickWall, Toronto, ...) come
  as the separate package `amadeos-backdrops-cde` (built by `scripts/package-cde-backdrops.sh`,
  installed to `/usr/share/amadeos/backdrops/cde`) and take their shades from the chosen backdrop
  color like in dtstyle; own `.pm`/`.bm` files (XPM/XBM) are found in `~/.dt/backdrops` and
  `~/.config/amadeos/backdrops`, pictures (PNG/JPEG) as before.
- **Input settings** (`input`): keyboard repeat and click, mouse handedness, double-click time and
  acceleration, and the bell, stored in `~/.config/amadeos/input.conf` and applied with `xset`,
  `xmodmap` and `xrdb` at login (`/etc/amadeos/autostart.d/10-amadeos-input`) and on Apply.
- **Screen saver** (`screen`, CDE's dtscreen): started by the session through
  `/etc/amadeos/autostart.d/50-amadeos-screen`; uses the X server's idle counter (MIT-SCREEN-SAVER,
  `libxss1`), shows a saver module (Qix, Swarm, Starfield, Floating Logo, Blank) and locks the screen
  after the configured time. Settings in `~/.config/amadeos/screen.conf`.
- **Front panel:** a CDE-style dock with clock, calendar, workspace switcher and
  drawers that list installed applications from their `.desktop` files.
- **Applications** are separate Debian packages, e.g.
  [amade-pad](https://github.com/datazuul/amade-pad); `.deb` files placed in
  `config/packages.chroot/` are installed into the image.

All Java components live in one JAR (`/opt/amadeos/amadeos.jar`); the first argument
selects the component, e.g. `dm`, `wm`, `panel`, `style` (Style Manager), `screen` (screen saver),
`input` (apply keyboard, mouse and bell settings) or `lock`.

The desktop themes and the Motif look come from
[amade-commons](https://github.com/datazuul/amade-commons), the library the amadeOS
applications ([amade-mail](https://github.com/datazuul/amade-mail),
[amade-pad](https://github.com/datazuul/amade-pad)) use as well. The Style Manager writes the
chosen theme to `~/.config/amadeos/theme.conf`; applications follow that file and switch
together with window frames and front panel. Gradle takes amade-commons from JitPack, or builds
a checkout in `../amade-commons` instead.

## Getting started

Requirements: Java 21, and for the image `live-build`, `sudo` and optionally QEMU.
[`CONTRIBUTING.md`](CONTRIBUTING.md) lists the packages per distribution.

```bash
./gradlew test         # unit and X11 integration tests (the latter need Xvfb)
./run-xephyr.sh        # window manager and panel in a nested X server
./run-greeter.sh       # login greeter in a nested X server (mock PAM)
./build.sh             # build artifacts/amadeos-amd64.iso (uses sudo for live-build)
./run-qemu.sh          # boot the ISO in QEMU
```

The live user is `amadeos` with the password `amadeos`.

## License

amadeOS is free software, licensed under the
[European Union Public Licence v. 1.2](LICENSE) (EUPL-1.2,
SPDX identifier `EUPL-1.2`). The EUPL is published by the European Commission and
is legally valid in all official languages of the EU; translations are available at
[interoperable-europe.ec.europa.eu](https://interoperable-europe.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

Copyright © 2026 datazuul.com and contributors.

The live image is an aggregation of Debian packages and separately packaged
applications; each of them keeps its own licence (see
`/usr/share/doc/<package>/copyright` on the running system). In particular, the
NsCDE icon theme built by `scripts/package-nscde-icons.sh` stays under the GPL-3.0
as a separate package, and the CDE backdrops packaged by `scripts/package-cde-backdrops.sh`
(`amadeos-backdrops-cde`, fetched from the CDE sources at build time) stay under the LGPL-2+. The screenshots in `docs/` show third-party software and
are not covered by this repository's licence.
