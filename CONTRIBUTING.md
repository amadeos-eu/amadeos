# Contributing to DazeOS

This document describes the development environment that is already configured and separates it from work that is only planned.

## Repository locations

The repository is located on the Windows filesystem at:

```text
C:\Laufwerk_D\projects-ext\github.com\datazuul\dazeOS
```

The same directory is accessed from Debian under WSL2 as:

```text
/mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS
```

Work directly in the WSL path. Do not create a second working copy inside the Linux filesystem for normal development. This keeps the checkout at its intended Windows location and makes it available to the surrounding Windows tools.

## Already configured environment

The verified environment is:

- WSL2 running the `Debian` distribution
- Debian GNU/Linux 13 (trixie)
- Linux user `ralf`
- Java/OpenJDK 21, including `java` and `javac`
- Git 2.47.3
- Gradle 9.3.1, available from `/mnt/c/Laufwerk_D/dev/gradle-9.3.1/bin/gradle`
- native build tools `gcc` and `make`
- Debian image tools `debootstrap`, `lb` (live-build), `xorriso`, and `grub-mkrescue`
- `qemu-system-x86_64` for planned virtual-machine boot tests

The tool commands above were found in the configured environment. The repository currently has Git initialized on branch `main`; it has no commits yet. At the time this document was written, the checkout contained the initial uncommitted files, including `README.md` and `.gitignore`.

The active `/etc/wsl.conf` is:

```ini
[boot]
systemd=true

[automount]
options=metadata
```

`systemd=true` enables systemd inside the Debian WSL instance. `options=metadata` enables Linux metadata handling for automatically mounted Windows drives, which improves permission and executable-bit behavior for Git and build tools.

## Recreating the WSL2 setup

The following commands describe the setup used for this checkout. Run the Windows commands in PowerShell and the Linux commands in the Debian WSL shell. The commands are included for reproducibility; they do not need to be repeated on the already configured instance.

### Install or start Debian under WSL2

From PowerShell:

```powershell
wsl.exe --status
wsl.exe --list --verbose

# Only if Debian is not installed yet:
wsl.exe --install -d Debian

wsl.exe -d Debian
```

The configured distribution is Debian GNU/Linux 13 (trixie), running as WSL2 user `ralf`.

### Configure WSL filesystem metadata

The checkout intentionally remains on the Windows-mounted path. WSL filesystem metadata is therefore enabled in `/etc/wsl.conf`:

```bash
sudo sh -c "printf '%s\\n' '[boot]' 'systemd=true' '[automount]' 'options=metadata' > /etc/wsl.conf"
```

Restart from PowerShell:

```powershell
wsl.exe --shutdown
wsl.exe -d Debian --user ralf
```

### Initialize the existing checkout

The empty Windows directory was recreated and initialized directly from WSL; no Linux-side copy was made:

```bash
cd /mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS
git init -b main
```

If creating a new checkout directory, do not remove a non-empty directory automatically. Verify its contents first and use the normal Git clone workflow where possible.

### Install the current build prerequisites

The following commands were used in the configured Debian instance. The first command was run as WSL root to install Git before the repository was initialized:

```powershell
wsl.exe -d Debian --user root -- apt-get update
wsl.exe -d Debian --user root -- apt-get install --yes git
```

The image-build and test toolchain was then installed:

```powershell
wsl.exe -d Debian --user root -- apt-get install --yes build-essential ca-certificates live-build debootstrap xorriso squashfs-tools grub-pc-bin grub-efi-amd64-bin mtools qemu-system-x86 ovmf openjdk-21-jdk
```

The installed Java baseline is OpenJDK 21. A future project decision may pin another JDK baseline, but the image and application builds must then be updated together.

## Applying WSL configuration changes

After changing `/etc/wsl.conf`, terminate the distribution from Windows PowerShell and start it again:

```powershell
wsl.exe --terminate Debian
wsl.exe -d Debian
```

A full WSL restart can be used when required:

```powershell
wsl.exe --shutdown
```

The configuration change and restart have already been applied for the current environment. Contributors changing their own WSL configuration must restart the distribution before relying on the new settings.

## Basic verification

From Debian WSL2:

```bash
whoami                         # ralf
. /etc/os-release && echo "$PRETTY_NAME ($VERSION_CODENAME)"
java -version                  # OpenJDK 21
javac -version
git --version
gradle --version
cd /mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS
git status --short --branch
```

The expected distribution identifier is `Debian GNU/Linux 13 (trixie)`. The expected WSL configuration contains `systemd=true` and `[automount] options=metadata`. Verify tool availability before starting a build:

```bash
command -v git gcc make lb debootstrap xorriso grub-mkrescue qemu-system-x86_64 java javac gradle
```

## Working on the Windows-mounted checkout

The checkout is intentionally under `/mnt/c`. This is already the configured workflow, but mounted Windows filesystems have limitations compared with a native Linux filesystem:

- metadata and permission behavior depend on the WSL automount options;
- file operations, directory traversal, and builds can be slower;
- Linux file notifications and locking semantics are not identical to native Linux filesystems;
- executable bits, symlinks, case sensitivity, and filename handling can differ from a Linux-native checkout;
- tools that expect native Linux filesystem semantics may fail or behave inconsistently;
- concurrent access from Windows and Linux tools can create locking or generated-file conflicts.

Keep generated output out of the source tree where practical, avoid running competing builds from both Windows and WSL, and do not treat a successful WSL build as proof that the image boots on real hardware. If a tool later demonstrates a mounted-filesystem incompatibility, use a separate Linux-native build workspace only as a documented exception; the repository's configured source checkout remains the `/mnt/c` path above.

## Git workflow

The repository was initialized with Git in the existing directory rather than copied elsewhere. From WSL:

```bash
cd /mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS
git status
git switch -c <topic-name>
```

Use focused commits and do not commit generated ISO images, VM disks, build caches, credentials, or local environment files. Check `.gitignore` before adding build output. Keep documentation in English unless a project decision establishes another language.

## Build and test status

The source repository currently contains the concept and initial README material; the complete image pipeline is not yet implemented. The following commands are planned rather than verified project build commands:

```bash
cd /mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS

# Validate the already installed Debian live-build inputs.
command -v lb debootstrap xorriso grub-mkrescue qemu-system-x86_64 java javac
```

The complete image pipeline is not implemented yet. Once it exists, the planned build flow will be:

```bash
cd /mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS

# Planned: once the project provides a live-build configuration.
lb config
lb build

# Planned: inspect the generated artifact and test it in a VM.
file live-image-amd64.hybrid.iso
qemu-system-x86_64 -enable-kvm -m 2048 -cdrom live-image-amd64.hybrid.iso
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



