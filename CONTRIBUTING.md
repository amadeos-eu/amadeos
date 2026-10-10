# Contributing to amadeOS

This document describes the development environment that is already configured and separates it from work that is only planned.

## Repository location

The repository is located at:

```text
/home/ralf/projects/github.com/datazuul/amadeos
```

## Already configured environment

The verified development environment is:

- Native Linux (Debian 13 trixie or Ubuntu 25.10 x86_64)
- Linux user `ralf`
- Java/OpenJDK 21+ (`java`, `javac`)
- Git 2.47+
- Gradle (via `/snap/bin/gradle` or local installation)
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

### 2. Install Java and Gradle

```bash
sudo apt-get install -y openjdk-21-jdk
```

If Gradle is not provided by your distribution's packages or you prefer snap:
```bash
sudo snap install --classic gradle
# or: sudo apt-get install -y gradle
```

### 3. Install X11 inspection and headless testing tools

For developing and testing the Java window manager without taking over your main desktop:
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

- **Platform baseline:** Java 21+ with Swing / Java2D.
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
| 📟 **Terminal** | `Categories=TerminalEmulator;System;` |
| 📋 **Diagnostics & Monitor** | `Categories=Monitor;System;` |
| ⚙️ **Settings & Tools** | `Categories=Settings;DesktopSettings;` |

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
Depends: default-jre | openjdk-21-jre | java21-runtime
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

## File permissions and Git executable flags

All shell scripts and hooks (`build.sh`, `scripts/build-image.sh`, chroot hooks in `config/hooks/`, and session scripts in `config/includes.chroot/`) must have their executable bit preserved in Git.

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
whoami                         # ralf
. /etc/os-release && echo "$PRETTY_NAME ($VERSION_CODENAME)"
java -version                  # OpenJDK 21+
javac -version
git --version
gradle --version
cd /home/ralf/projects/github.com/datazuul/amadeos
git status --short --branch
command -v git gcc make lb debootstrap xorriso grub-mkrescue qemu-system-x86_64 java javac gradle
```

## Git workflow

Work directly in the repository:

```bash
cd /home/ralf/projects/github.com/datazuul/amadeos
git status
git switch -c <topic-name>
```

Use focused commits and do not commit generated ISO images, VM disks, build caches, credentials, or local environment files. Check `.gitignore` before adding build output. Keep documentation in English unless a project decision establishes another language.

## Build and test status

The source repository contains the Java prototype and the `build.sh` live-image entrypoint.

```bash
cd /home/ralf/projects/github.com/datazuul/amadeos

# Run the Java tests and build the first live ISO.
gradle clean test
./build.sh
```

`build.sh` builds the JAR, sets up the live-build tree, and executes `live-build` in a temporary workspace (by default `/tmp/amadeos-live-build`, configurable via `AMADEOS_BUILD_ROOT`).

The build currently embeds the Swing demonstration and the Xorg/OpenJDK package set. It does not yet start the Java window manager automatically. Once an ISO has been built, inspect and test it with:

```bash
cd /home/ralf/projects/github.com/datazuul/amadeos

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
- Xorg startup and non-reparenting window-manager behavior;
- focus, transient windows, popups, multiple displays, and ordinary non-Java X11 clients;
- security-update and rebuild procedures.

## Scope of contributions

The initial project benefits most from small, testable contributions: build reproducibility, documented package inputs, Java/X11 experiments, compatibility tests, hardware observations, and concise documentation. Before adding a dependency or changing the base stack, record its purpose, licensing implications, update path, and effect on the live image. Architecture decisions belong in `CONCEPT.md`; this file should describe reproducible contributor procedures and verified environment facts.



