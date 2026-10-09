# DazeOS

**DazeOS** — *Digital Autonomy, Zero Lock-in, Empowerment*.

DazeOS is a free, Java-powered European desktop operating system concept.
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

Run the unit tests with `gradle test` (or `gradlew.bat test` when a wrapper is
provided) and the Swing demo with `gradle run`.

The first Debian live-build entrypoint is `./build.sh`. It builds the JAR,
embeds it into the live root filesystem, and invokes `live-build` to create
`artifacts/dazeos-amd64.iso`. The live-build step requires root privileges and
is invoked through `sudo` when the script is run as a normal user.

The generated image currently provides the Xorg and Java runtime packages but
does not start a graphical session automatically. After booting the live
system, `startx` uses `/etc/skel/.xinitrc` for newly created live users and
starts the Swing demonstration. This is an early image milestone, not yet the
final DazeOS desktop.

The X11 event loop, ICCCM/EWMH behavior, real client lifecycle, native bindings,
and automatic Java window-manager startup are intentionally not implemented in
this iteration. The current live-build configuration is deliberately minimal
and still needs BIOS/UEFI and QEMU validation.

## Development environment

The project is developed directly in Debian under WSL2 at:

```text
/mnt/c/Laufwerk_D/projects-ext/github.com/datazuul/dazeOS
```

Build tooling and the first image pipeline will be added incrementally.

