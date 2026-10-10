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



