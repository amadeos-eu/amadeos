# 11. Getting the Image

amadeOS comes as one file, the *image*, named after the version: `amadeos-1.0.0-amd64.iso` for amadeOS 1.0.0. It contains the live system and the installer, and it is written onto a USB stick as it is (chapter 12).

## Downloading the image

Every amadeOS release offers its image for download on the [download page](https://www.amadeos.eu/download.html) and on the [releases page](https://github.com/amadeos-eu/amadeos/releases/latest) of the amadeos repository, for example `amadeos-1.0.0-amd64.iso` for version 1.0.0, together with its checksum file and the release notes. The image is about 1.5 GB.

## Building the image yourself

Instead of downloading it, you can build the image yourself. On a computer with Debian or Ubuntu Linux, the script `buildDistribution.sh` of the [amadeos](https://github.com/amadeos-eu/amadeos) repository builds every package of amadeOS from the current source code and then the image:

```bash
git clone https://github.com/amadeos-eu/amadeos.git
cd amadeos
./buildDistribution.sh
```

It fetches the other repositories (the desktop, the applications and the games) next to `amadeos`, builds them and puts the image into `artifacts/`, as `amadeos-<version>-amd64.iso`. It needs Java 25, `live-build`, `sudo` and an internet connection, and it takes a while, because it builds and tests every package. Chapter 62 explains the build and its options in detail; [CONTRIBUTING.md](https://github.com/amadeos-eu/amadeos/blob/main/CONTRIBUTING.md) lists the packages to install first.

## Checking the image

Next to the image lies a checksum file, `amadeos-1.0.0-amd64.iso.sha256`. It lets you check that the image arrived complete and unchanged, which matters most for an image downloaded from the internet. On Linux:

```bash
sha256sum -c amadeos-1.0.0-amd64.iso.sha256
```

The answer `amadeos-1.0.0-amd64.iso: OK` means the image is fine. On Windows, the PowerShell command `Get-FileHash amadeos-1.0.0-amd64.iso` prints the checksum, which you compare with the one in the `.sha256` file; on macOS, `shasum -a 256 amadeos-1.0.0-amd64.iso` does the same.

!!! sovereignty "Your data"
    A checksum proves that the file is the one that was published, not that the publisher is trustworthy. That is why amadeOS publishes its whole source code and builds the image from it with a script anyone can run: you can check what is in the image, not only that it arrived intact.
