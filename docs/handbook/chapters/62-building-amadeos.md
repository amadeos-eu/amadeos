# 62. Building amadeOS Yourself

You can build the amadeOS image yourself, from the same sources and with the same scripts that build the official one. This chapter shows how, and how to change what goes into it.

## What you need

- A computer with **Debian 13** (or Ubuntu 25.10), 64-bit. amadeOS itself works too, once the packages below are installed.
- Several gigabytes of free disk space, a network connection, and some patience: the first build downloads every Debian package of the image.
- Administrator rights: live-build has to run as root, and the script asks for your password through `sudo`.

Install the tools:

```sh
sudo apt install git live-build debootstrap xorriso squashfs-tools mtools \
    grub-pc-bin grub-efi-amd64-bin syslinux-utils openjdk-25-jdk python3-venv \
    qemu-system-x86 ovmf
```

The Java compiler builds the amadeOS packages, `python3-venv` this book, QEMU lets you start the image without a USB stick. Gradle, the build tool of the Java packages, comes with each repository and needs no installation.

## The whole distribution in one step

```sh
mkdir amadeos-src && cd amadeos-src
git clone https://github.com/amadeos-eu/amadeos.git
cd amadeos
./buildDistribution.sh
```

`buildDistribution.sh` clones every repository of the distribution next to `amadeos` (the list is in `repositories.list`), builds the desktop, every application and every game with their tests, puts their packages into `config/packages.chroot/` and builds the image. At the end it is in `artifacts/amadeos-<version>-amd64.iso`, with its checksum next to it. The version is that of the amadeos checkout: exactly `1.0.0` on the tagged `main`, `X.Y.Z-pre.0` on `release` and `X.Y.Z-dev.0` on `develop`; `AMADEOS_VERSION=...` sets it by hand. `artifacts/amadeos-amd64.iso` links to the newest image, and an older image is deleted when a new one is built.

| Option | What it does |
|---|---|
| `--no-clone` | Builds only what is already checked out. |
| `--no-pull` | Builds the checkouts as they are, with your own changes. |
| `--skip-tests` | Skips the tests; faster, but you notice mistakes later. |
| `--apps "amade-pad amade-mail"` | Builds only these applications. |
| `--quick` | Packs the previous image again with the new packages, without a full live-build run. |

## Trying the image

```sh
./run-qemu.sh                         # the live system in a virtual machine
./run-qemu.sh --install-disk          # ... with an empty disk to install onto
./run-qemu.sh --boot-disk             # start the installed system
./run-qemu.sh --boot-disk --uefi      # ... with UEFI firmware instead of BIOS
```

`QEMU_RAM=4096 ./run-qemu.sh` gives the virtual machine more memory. Chapter 12 shows how to write the image to a USB stick.

## Changing the image

The image is described by files in the `amadeos` repository:

| What | Where |
|---|---|
| The Debian packages in the image | `config/package-lists/amadeos.list.chroot`, one package per line |
| Further `.deb` files | `config/packages.chroot/`: everything there is installed |
| Files copied into the image as they are | `config/includes.chroot/`, laid out like the root of the file system |
| Settings of the live user: name, groups, keyboard, time zone | `config/includes.chroot/etc/live/config.conf` |
| Scripts that run inside the image while it is built | `config/hooks/normal/` |
| The boot menu of BIOS computers | `config/bootloaders/isolinux/` |

For example, to have GIMP in your image, add the line `gimp` to the package list and run `./build.sh`. `build.sh` builds the image from what is there, without building the Java packages again; `scripts/check-config.sh` checks the configuration first, as the automatic build of the project does.

!!! tip
    Add one change at a time and try it in QEMU. A package that asks questions during installation, or one that brings a desktop environment of its own, can make the build fail or the image much larger.

## Changing the desktop

The desktop is developed in `amadeos-system`. You do not need a new image to try a change:

```sh
cd ../amadeos-system
./gradlew build                 # build and test every module
./gradlew :settings:run         # start Settings from the build
wm/run-xephyr.sh                # window manager and Front Panel in a window of their own
dm/run-greeter.sh               # the login greeter in a window
./gradlew deb                   # the packages, in <module>/build/distributions/
```

`sudo dpkg -i settings/build/distributions/amadeos-settings_*.deb` installs a changed package on a running amadeOS; log out and in again to see it everywhere. `./gradlew installToAmadeOs` puts the packages into `../amadeos/config/packages.chroot/` for the next image.

## This book

The handbook is in `docs/handbook` of the `amadeos` repository, written in Markdown and made into web pages by MkDocs:

```sh
cd docs/handbook
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/mkdocs serve          # the book at http://127.0.0.1:8000, updated as you edit
screenshots/shoot.sh            # take the pictures again, in a virtual screen
```

Corrections and new chapters are welcome, like any other contribution: see `CONTRIBUTING.md` and <https://github.com/amadeos-eu/amadeos/issues>.

??? hood "Under the hood"
    `build.sh` runs `scripts/build-image.sh`, which prepares a live-build tree in `/tmp/amadeos-live-build` (or `AMADEOS_BUILD_ROOT`), adds the kernel command line and the UEFI boot loader and runs `lb build`. Packages the image needs but that live-build does not build itself are made by scripts of their own: `scripts/package-nscde-icons.sh` (the icon theme), `scripts/package-cde-backdrops.sh` (the CDE backdrops) and `scripts/package-handbook.sh` (this book as `amadeos-handbook`). The Java packages are built with Gradle; with `amade-commons` checked out next to an application, the application uses that checkout instead of the published version.
