# Contributing to amadeOS

This document describes the development environment that is already configured and separates it from work that is only planned.

## Getting the source

```bash
git clone https://github.com/datazuul/amadeos.git
cd amadeos
```

## Already configured environment

The verified development environment is:

- Native Linux (Debian 13 trixie or Ubuntu 25.10 x86_64)
- Git 2.47+
- Java/OpenJDK 25+ for the packages that go into the image (amadeos-system, the applications; each
  brings its Gradle wrapper). This repository itself holds no Java code.
- Native build tools `build-essential` (`gcc`, `make`)
- Debian live image tools `debootstrap`, `lb` (live-build), `xorriso`, `squashfs-tools`, `mtools`, `grub-pc-bin`, `grub-efi-amd64-bin`
- Virtual machine testing: `qemu-system-x86_64`, `ovmf`
- X11 testing tools: `xvfb`, `x11-utils`, `xterm`

## Native Linux setup (Debian / Ubuntu)

To set up a fresh native Linux host for amadeOS development and live image building:

### 1. Install image build and virtualization prerequisites

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    ca-certificates \
    live-build \
    debootstrap \
    xorriso \
    squashfs-tools \
    mtools \
    grub-pc-bin \
    grub-efi-amd64-bin \
    syslinux-utils \
    qemu-system-x86 \
    ovmf
```

### 2. Install Java

Needed to build the desktop package (`../amadeos-system`) and the applications; they use their Gradle
wrapper.

```bash
sudo apt-get install -y openjdk-25-jdk
```

### 3. Install X11 inspection and headless testing tools

For the X11 integration tests of the desktop (amadeos-system) and for trying the window manager in a
nested X server without taking over your main desktop:
```bash
sudo apt-get install -y \
    xvfb \
    x11-utils \
    x11-apps \
    xterm \
    libx11-dev
```

* `xvfb`: Provides a virtual framebuffer X server for headless tests and automated testing of the window manager.
* `x11-utils` (`xdpyinfo`, `xwininfo`, `xprop`): Inspects X11 window tree, properties, and events.
* `xterm` / `x11-apps`: Lightweight test client applications to test window placement, focus, and lifecycle.
* `libx11-dev`: Header files and shared libraries for validating JNA / native bindings.

## Developing independent applications (.deb)

User-space applications (e.g. text editors, file managers, calculators, system monitors) are developed in **independent repositories** and packaged as standard Debian `.deb` packages, rather than being hardcoded into the base OS.

Example reference implementation: [`datazuul/amade-pad`](https://github.com/datazuul/amade-pad).

### 1. Application standards & Motif 3D styling

- **Platform baseline:** Java 25+ with Swing / Java2D.
- **Motif 3D aesthetic:** Avoid default Swing/Metal "Ocean" blue gradients. Applications should use the warm Motif `#CEC2BB` palette with 3D chiseled beveled borders matching the amadeOS window buttons:
  - Base color: `#CEC2BB`
  - Highlight / Soft Highlight: `#FFFFFF` / `#EAE5E2`
  - Shadow / Dark Shadow: `#8C827A` / `#423B35`
  - Sunken / Pressed: `#BAAFA8` (with $+1\text{px}$ text/icon shift on click)
- **Central Look-and-Feel:** Call `AmadeUI.install()` or rely on system-wide `swing.properties` (`swing.defaultlaf=com.sun.java.swing.plaf.motif.MotifLookAndFeel`) so all buttons, dialogs, scrollbars, and menus use authentic Motif 3D styling.

### 2. Debian package filesystem layout

Every independent application `.deb` package should install to standard system locations:

| Path | Mode | Description |
| :--- | :--- | :--- |
| `/usr/bin/<app-name>` | `0755` | Shell wrapper script (`exec /usr/bin/java -jar /opt/<app>/<app>.jar "$@"`) |
| `/opt/<app-name>/<app-name>.jar` | `0644` | Application fat JAR |
| `/usr/share/applications/<app-name>.desktop` | `0644` | Freedesktop desktop entry |
| `/usr/share/icons/hicolor/48x48/apps/<app-name>.png` | `0644` | Application icon |

### 3. XDG desktop entry & Front Panel drawer mapping

amadeOS uses dynamic XDG desktop entry discovery (`XdgApplicationManager`). The `Categories` field in your `.desktop` file automatically binds your application to the corresponding CDE Front Panel drawer:

| Front Panel Drawer | Primary Categories |
| :--- | :--- |
| 📁 **File Manager** | `Categories=FileManager;System;` |
| 📝 **Text Editor** | `Categories=TextEditor;Utility;` |
| ✉️ **Mail** | `Categories=Network;Email;` |
| 🎵 **Sound & Video** | `Categories=AudioVideo;Audio;Player;` |
| 🎨 **Graphics** | `Categories=Graphics;Scanning;` (also `RasterGraphics`, `VectorGraphics`, `Photography`, `Viewer`) |
| 🖨️ **Printer** | `Categories=Printing;Settings;` |
| ❓ **Help** | `Categories=Documentation;Help;` |
| 🛠️ **Tools** | `Categories=Settings;` or `Categories=System;` (after the fixed entries: Settings, Application Manager, terminals, logs, system information) |

The first application found in a category also becomes the slot's primary click action. Categories without a drawer (e.g. `Development`, `Office`) are listed in the Application Manager.

Example `amade-pad.desktop`:
```ini
[Desktop Entry]
Type=Application
Version=1.0
Name=amadeOS Text Editor
GenericName=Text Editor
Comment=Lightweight Motif/CDE-style text editor
Icon=amade-pad
Exec=/usr/bin/amade-pad %F
Terminal=false
Categories=Utility;TextEditor;
MimeType=text/plain;text/x-java;text/x-c;text/x-shellscript;
```

### 4. Gradle Debian packaging reference

In your application's `build.gradle`, you can use `dpkg-deb` to build standard rootless packages and drop them into amadeOS:

```groovy
tasks.register('deb') {
    dependsOn jar
    group = 'distribution'
    doLast {
        def buildDirFile = layout.buildDirectory.get().asFile
        def stagingDir = new File(buildDirFile, "deb-staging")
        delete(stagingDir)

        def optDir = new File(stagingDir, "opt/amade-pad")
        def binDir = new File(stagingDir, "usr/bin")
        def appDir = new File(stagingDir, "usr/share/applications")
        def iconDir = new File(stagingDir, "usr/share/icons/hicolor/48x48/apps")
        def debianDir = new File(stagingDir, "DEBIAN")
        def distDir = new File(buildDirFile, "distributions")

        [optDir, binDir, appDir, iconDir, debianDir, distDir]*.mkdirs()

        // 1. Copy JAR
        copy { from jar.archiveFile; into optDir; rename { 'amade-pad.jar' } }

        // 2. Launcher script
        def launcher = new File(binDir, "amade-pad")
        launcher.text = "#!/bin/sh\nexec /usr/bin/java -jar /opt/amade-pad/amade-pad.jar \"\$@\"\n"
        launcher.setExecutable(true, false)

        // 3. Desktop entry and icons
        copy { from "src/main/resources/amade-pad.desktop"; into appDir }
        copy { from "src/main/resources/icons/amade-pad.png"; into iconDir }

        // 4. DEBIAN/control
        new File(debianDir, "control").text = """Package: amade-pad
Version: ${project.version}
Section: editors
Priority: optional
Architecture: all
Depends: openjdk-25-jre | java-runtime (>= 25)
Maintainer: amadeOS Project <developers@datazuul.com>
Description: Authentic Motif/CDE-styled text editor for amadeOS
"""

        // 5. Build .deb package
        def debFile = new File(distDir, "amade-pad_${project.version}_all.deb")
        new ProcessBuilder("dpkg-deb", "--root-owner-group", "--build", stagingDir.absolutePath, debFile.absolutePath)
                .inheritIO().start().waitFor()
    }
}

// Automated drop-in deployment to amadeOS
tasks.register('installToAmadeOs') {
    dependsOn 'deb'
    doLast {
        def targetDir = file("../amadeos/config/packages.chroot")
        targetDir.mkdirs()
        def debFile = new File(layout.buildDirectory.get().asFile, "distributions/amade-pad_${project.version}_all.deb")
        copy { from debFile; into targetDir }
    }
}
```

### 5. Testing in amadeOS

1. In your application repo, run `./gradlew installToAmadeOs`.
2. The package is staged in `amadeos/config/packages.chroot/`.
3. Rebuild the live image:
   - Full build: `sudo ./build.sh`
   - Quick repack: `sudo AMADEOS_QUICK=1 ./build.sh`
4. Test in QEMU: `./run-qemu.sh`. Your application will be installed and appear in the CDE Front Panel drawer.

## The desktop

The window manager, front panel, display manager, Style Manager, lock and screen saver are the module
`desktop` of [amadeos-system](https://github.com/datazuul/amadeos-system); its `desktop/README.md`
describes the components and how to add front panel slots and widgets. This repository builds the
image around that package.

## Icons

Panel and desktop icons are looked up by **icon key** in `IconManager` of the desktop (amadeos-system,
`desktop/src/main/java/eu/amadeos/wm/theme/`). Each key maps to a list of Freedesktop icon names (`FREEDESKTOP_NAMES`). The current icon theme (default: NsCDE) is searched for each name in turn, then its inherited themes and `hicolor`; the first match wins. If nothing is found, a simple icon is drawn in code (`generatePixmaps`).

Because every name is tried in the current theme before falling back to `hicolor`, an icon installed to `hicolor` does not win against a later name that NsCDE has. To give amadeOS its own look, add the icon to the NsCDE theme, which this repository builds:

1. Draw the icon as SVG in `icons/src/amadeos-<name>.svg`. Keep the NsCDE look: 48×48 canvas, flat greys with 1 px Motif bevels, black outlines, few colours.
2. Render the sizes NsCDE provides into `icons/NsCDE/<size>x<size>/<context>/`, where `<context>` is the Freedesktop context (`apps`, `categories`, `devices`, `places`, …):
   ```bash
   for s in 16 22 32 48; do
     rsvg-convert -w $s -h $s icons/src/amadeos-<name>.svg \
       -o icons/NsCDE/${s}x${s}/categories/amadeos-<name>.png
   done
   ```
   Check the 16 px version; small details may need simplifying.
3. In amadeos-system, put `amadeos-<name>` first in the key's list in `FREEDESKTOP_NAMES`, keeping the standard names after it as a fallback for other icon themes:
   ```java
   map.put("multimedia", List.of("amadeos-multimedia", "applications-multimedia", "audio-x-generic"));
   ```
4. Bump `PACKAGE_REVISION` in `scripts/package-nscde-icons.sh` and rebuild the theme package:
   ```bash
   ./scripts/package-nscde-icons.sh --install-iso     # for the live image
   ./scripts/package-nscde-icons.sh --install-local   # for Xephyr on the host (replaces ~/.local/share/icons/NsCDE)
   ```
   The script downloads NsCDE from upstream, copies `icons/NsCDE/` over it and builds `nscde-icon-theme_<version>-<revision>_all.deb`, replacing the previous build in `config/packages.chroot/`.

The background of the BIOS boot menu is drawn the same way: edit `icons/src/boot-splash.svg` and render it with `rsvg-convert -w 640 -h 480 icons/src/boot-splash.svg -o config/bootloaders/isolinux/splash.png`. Keep the lower part (below y = 330) free for the menu. The default wallpaper comes from `icons/src/wallpaper.svg` and is rendered to both places it is used:

```bash
for f in config/includes.chroot/usr/share/backgrounds/amadeos/wallpaper.png ../amadeos-system/desktop/src/main/resources/wallpapers/default.png; do
  rsvg-convert -w 1920 -h 1080 icons/src/wallpaper.svg -o "$f"
done
```

Always use the `amadeos-` prefix: upstream icons are never replaced, and the theme's `AUTHORS` file marks the `amadeos-*` icons as amadeOS's own (EUPL-1.2), separate from the GPL-3.0 NsCDE icons.

## File permissions and Git executable flags

All shell scripts and hooks (`build.sh`, `scripts/build-image.sh`, chroot hooks in `config/hooks/`, and the scripts in `config/includes.chroot/usr/local/bin/`) must have their executable bit preserved in Git; `scripts/check-config.sh` checks it.

On Linux/Unix:
```bash
# Make the file executable locally
chmod +x build.sh

# Record the executable permission bit (100755) in Git's index
git update-index --chmod=+x build.sh
```

Git records file modes as either `100644` (regular file) or `100755` (executable file). Committing with `--chmod=+x` ensures that checkouts and fresh clones on any Linux machine will automatically have executable permissions.

## Development verification

Verify tool availability before starting a build:

```bash
. /etc/os-release && echo "$PRETTY_NAME ($VERSION_CODENAME)"
git --version
java -version                  # OpenJDK 25+, for amadeos-system and the applications
cd amadeos
git status --short --branch
command -v git lb debootstrap xorriso grub-mkstandalone mkfs.fat mcopy qemu-system-x86_64 java
scripts/check-config.sh        # the checks CI runs on the image configuration
```

## Git workflow

Work on a topic branch from `develop`, the default branch, and open the pull request against `develop`:

```bash
cd amadeos
git switch develop && git pull
git switch -c <topic-name>
```

### Commits and versions

Every commit subject is a [Conventional Commit](https://www.conventionalcommits.org/): `type(scope): text`.

| Type | For | Version |
|---|---|---|
| `feat` | a new feature | minor (1.1.0 → 1.2.0) |
| `fix`, `perf` | a bug fix, a speed-up | patch (1.1.0 → 1.1.1) |
| `docs`, `refactor`, `test`, `build`, `ci`, `chore`, `style`, `revert` | everything else | patch |
| `feat!:`, `fix(wm)!:`, or a `BREAKING CHANGE:` line in the body | a breaking change | major (1.1.0 → 2.0.0) |

Examples: `feat(panel): battery cell in the status slot`, `fix(wm): closing a dialog activates its owner`,
`docs(handbook): chapter 51 versions and releases`. The scope is optional, lower case, the area of the change.

Nobody writes a version by hand. CI computes it from the commits since the last tag `vX.Y.Z`
(`scripts/next-version.sh` of [amadeos-ci](https://github.com/datazuul/amadeos-ci)); a repository without a tag starts at 1.0.0.

| Branch | Built as | Debian version | Published |
|---|---|---|---|
| `develop` | `1.2.0-dev.57` | `1.2.0~dev.57` | workflow artifact (apt suite `dev`, M16) |
| `release` | `1.2.0-pre.61` | `1.2.0~pre.61` | workflow artifact (apt suite `testing`) |
| `main` | `1.2.0` | `1.2.0` | tag `v1.2.0`, GitHub Release with the packages (apt suite `stable`) |

`release` and `main` only move forward through the **Promote** workflow of amadeos-ci
(Actions → Promote → Run workflow: to `release` or `main`, all repositories or a list), which runs
`scripts/promote.sh` there. Libraries go first; an app is promoted to main only when its amade-commons or
amade-game-engine pin is a released version. The Application Developer's Handbook explains the whole
workflow in chapter 51, "Versions and Releases".

Use focused commits and do not commit generated ISO images, VM disks, build caches, credentials, or local environment files. Check `.gitignore` before adding build output. Keep documentation in English unless a project decision establishes another language.

## Build and test status

This repository contains the live-build configuration and the `build.sh` live-image entrypoint; the
desktop and the applications are tested in their own repositories.

```bash
cd amadeos

# Check the configuration and build the live ISO (needs the desktop packages in config/packages.chroot).
scripts/check-config.sh
./build.sh
```

`build.sh` checks the configuration, sets up the live-build tree, and executes `live-build` in a temporary workspace (by default `/tmp/amadeos-live-build`, configurable via `AMADEOS_BUILD_ROOT`). The image installs the packages from `config/packages.chroot/` (the desktop packages `amadeos-dm`, `amadeos-session`, `amadeos-wm`, `amadeos-panel-cde` and `amadeos-settings` among them) and starts the display manager at boot. Once an ISO has been built, inspect and test it with:

```bash
cd amadeos

# Inspect the generated artifact.
file artifacts/amadeos-amd64.iso
sha256sum -c artifacts/amadeos-amd64.iso.sha256

# BIOS smoke test with QEMU (with USB tablet for seamless mouse integration):
qemu-system-x86_64 -enable-kvm -m 2048 -usb -device usb-tablet -cdrom artifacts/amadeos-amd64.iso

# UEFI smoke test with QEMU & OVMF:
qemu-system-x86_64 -enable-kvm -m 2048 -bios /usr/share/ovmf/OVMF.fd -usb -device usb-tablet -cdrom artifacts/amadeos-amd64.iso
```

The exact package list, build directory, ISO filename, boot parameters, and QEMU options must be committed with the image pipeline when they become stable. Do not report `lb build`, ISO booting, BIOS support, UEFI support, or Java window-manager tests as complete until those tests have actually been run and their results recorded.

Future validation should cover at least:

- a clean, repeatable Debian live-image build;
- ISO integrity and expected filesystem contents;
- BIOS and UEFI boot in a virtual machine and on representative hardware;
- startup of the Java runtime and representative Swing/AWT applications;
- Xorg startup and reparenting window-manager behavior;
- focus, transient windows, popups, multiple displays, and ordinary non-Java X11 clients;
- security-update and rebuild procedures.

## Scope of contributions

The initial project benefits most from small, testable contributions: build reproducibility, documented package inputs, Java/X11 experiments, compatibility tests, hardware observations, and concise documentation. Before adding a dependency or changing the base stack, record its purpose, licensing implications, update path, and effect on the live image. Architecture decisions belong in `CONCEPT.md`; this file should describe reproducible contributor procedures and verified environment facts.




## Licensing of contributions

amadeOS is licensed under the EUPL-1.2 (see `LICENSE`). By submitting a contribution
you agree that it is licensed under the same terms. Only add third-party code whose
licence allows distribution under the EUPL-1.2, or keep it in a separately packaged
component with its own licence (as done for the NsCDE icon theme and the CDE backdrops). Note that code
under a licence listed in the EUPL appendix (e.g. GPL) can absorb EUPL code, but not
the other way round, so GPL-only code cannot be merged into this repository.
