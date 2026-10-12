# amadeOS

**amadeOS** — *Digital Autonomy, Zero Lock-in, Empowerment*.

amadeOS is a free, Java-powered European desktop operating system concept.
The initial target is an x86-64 bootable Debian-based USB image with:

- Debian Stable Minimal
- Xorg/X11
- a Java-based non-reparenting floating window manager
- Swing applications
- BIOS and UEFI boot support

## Java MVP

The first executable iteration is a small Java 21 Gradle prototype in the root
project. It separates pure window registry/floating-layout logic from the
`X11Adapter` boundary and includes a Swing demonstration application. The current
adapter is logging-only: it makes no X11 or native calls and therefore does not
manage the host desktop. Details and limitations are documented in
[`java-wm/README.md`](java-wm/README.md).

Run the unit tests with `gradle test` and the Swing demo with `gradle run`.

The first Debian live-build entrypoint is `./build.sh`. It builds the JAR,
embeds it into the live root filesystem, and invokes `live-build` to create
`artifacts/amadeos-amd64.iso`. The live-build step requires root privileges and
is invoked through `sudo` when the script is run as a normal user.

The generated image currently provides the Xorg and Java runtime packages but
does not start a graphical session automatically. After booting the live
system, `startx` uses `/etc/skel/.xinitrc` for newly created live users and
starts the Swing demonstration. This is an early image milestone, not yet the
final amadeOS desktop.

The X11 event loop, ICCCM/EWMH behavior, real client lifecycle, native bindings,
and automatic Java window-manager startup are intentionally not implemented in
this iteration. The current live-build configuration is deliberately minimal
and still needs BIOS/UEFI and QEMU validation.

## Development environment

The project is developed in a native Linux environment (Debian / Ubuntu) at:

```text
/home/ralf/projects/github.com/datazuul/amadeos
```

Build tooling and the first image pipeline will be added incrementally.


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
as a separate package. The screenshots in `docs/` show third-party software and
are not covered by this repository's licence.
