# DazeOS roadmap

This roadmap records the verified project status and the next implementation steps. It deliberately separates completed work, work in progress, and work that still requires evidence. No milestone is considered complete merely because the corresponding files or scripts exist.

Status date: 2026-10-09

## Project direction

DazeOS is a free, European, Java-centred desktop system based on a minimal Debian x86-64 live image. The first desktop target is:

- Linux and Debian userland for hardware support and low-level system services
- Xorg/X11 for the initial display stack
- a Java non-reparenting floating window manager
- separate Swing/AWT applications
- a bootable ISO for BIOS and UEFI systems

The architectural decisions and rejected alternatives are documented in [`CONCEPT.md`](CONCEPT.md).

## Current status

### Verified and available

- The repository contains the initial Java window-manager model and Swing demonstration.
- The Java code separates pure window registry/layout logic from the `X11Adapter` boundary.
- `LoggingX11Adapter` provides a safe, non-native adapter for the current prototype.
- The Java build has been run successfully with OpenJDK 21 and the existing unit tests passed.
- The application JAR has an executable manifest pointing to `SwingDemoApplication`.
- The repository contains an initial Debian `live-build` configuration for trixie and amd64.
- The image configuration includes Xorg, OpenJDK 21 JRE, fonts, certificates, and the demo JAR.
- The build script uses a dedicated temporary build workspace such as `/tmp/dazeos-live-build`.
- The build script creates `artifacts/dazeos-amd64.iso` and SHA-256 checksum when `live-build` completes successfully.
- A bootable Debian 13 (Trixie) live ISO (`artifacts/dazeos-amd64.iso`, 414 MiB) was successfully built on native Linux, and its SHA-256 checksum verified (`OK`).
- BIOS boot in QEMU verified (`artifacts/dazeos-amd64.iso` boots cleanly to Xorg).
- Automatic autologin on tty1, automatic Xorg start, and launcher execution of `dazeos-session` verified.
- Swing demo application and mouse pointer interaction (including button clicks) verified running inside QEMU.
- Native Linux, the Java toolchain, live-build prerequisites, QEMU, and the documented development workflow are available in the configured environment.

### In progress or incomplete

- The window manager has no real X11 connection, native binding, root-window ownership, or event loop.
- Client lifecycle handling, focus handling, close requests, transient windows, and ICCCM/EWMH support are not implemented.
- The Swing demo is an application demonstration; it does not manage the host desktop.
- Dual-firmware (UEFI) boot via GRUB EFI / xorriso is not yet embedded.

### Not yet verified

- UEFI boot in QEMU.
- Real hardware, graphics acceleration, firmware, WLAN, audio, suspend/resume, multiple displays, and USB boot have not been tested.
- Security updates, image signing, rollback, persistence, installation, and release procedures are not defined.

## Milestones

### M0 — Restore a reproducible build (Completed)

**Goal:** Produce the first inspectable ISO from a clean checkout. (Achieved 2026-10-09)

1. Inspect the generated live-build configuration immediately after the archive/chroot archive stages:
   - `chroot/etc/apt/sources.list*`
   - `chroot/var/lib/apt/lists/`
   - live-build configuration files and logs
2. From the generated chroot, check APT visibility with `apt-cache policy` for representative packages such as `xserver-xorg`, `openjdk-21-jre`, and `live-boot`.
3. Verify that the configured Debian mirror, distribution (`trixie`), archive areas, DNS, and proxy handling are available inside the chroot.
4. Make the smallest configuration fix required. Prefer explicit mirror and archive configuration over undocumented host-specific behavior.
5. Run `./build.sh` and retain the relevant log output.
6. Verify the resulting artifact:

   ```bash
   file artifacts/dazeos-amd64.iso
   sha256sum -c artifacts/dazeos-amd64.iso.sha256
   ```

**Exit criteria:** A clean build creates a non-empty ISO and its checksum verifies. The build result and any required environment assumptions are documented.

### M1 — Boot and inspect the live image (BIOS Verified)

**Goal:** Demonstrate that the image boots through both firmware paths and contains the intended runtime.

1. **BIOS boot in QEMU (Verified):**
   ```bash
   qemu-system-x86_64 -enable-kvm -m 2048 -usb -device usb-tablet -cdrom artifacts/dazeos-amd64.iso
   ```
   - Boots via Isolinux menu to live Linux 6.12 kernel.
   - Automatically logs in as `dazeos` on tty1.
   - Automatically starts Xorg and launches `dazeos-session`.
   - Displays `SwingDemoApplication` with fully functional mouse pointer tracking and interactive button clicks.
2. **UEFI boot in QEMU (In progress):**
   ```bash
   qemu-system-x86_64 -enable-kvm -m 2048 -bios /usr/share/ovmf/OVMF.fd -usb -device usb-tablet -cdrom artifacts/dazeos-amd64.iso
   ```
   - The current ISO uses Syslinux/Isolinux (BIOS only); OVMF enters UEFI shell because EFI system partition (`/EFI/BOOT/BOOTX64.EFI`) is not yet embedded.
3. Confirm the live system reaches a shell and can locate the Java runtime, demo JAR, Xorg, and session scripts. (Verified)
4. Graphical session and mouse interaction verified.

**Exit criteria:** BIOS boot evidenced, live root filesystem usable, Java runtime and Xorg package set confirmed functional. UEFI bootloader integration remains for full dual-firmware compliance.

### M2 — Make the session launcher reliable (Completed)

**Goal:** Provide a predictable Xorg session entrypoint before native WM integration.

1. Validated the relationship between `live-config`, `agetty` autologin on tty1, `/etc/skel/.xinitrc`, `dazeos-session`, and `startx`.
2. `dazeos-session` validates Java runtime and application JAR availability, writes structured diagnostics to `~/.dazeos-session.log`, and launches a fallback `xterm` with diagnostic output if components are missing.
3. Included `xterm` in image package lists as a debugging and client test terminal.

**Exit criteria:** The documented session launcher starts the desktop cleanly and reports actionable diagnostics on failure. (Achieved 2026-10-10)

### M3 — Implement the native X11 boundary

**Goal:** Connect the Java WM prototype to a real X11 server without mixing native concerns into the pure model.

1. Choose and pin the initial binding strategy, currently JNA with `libX11` is the preferred prototype route.
2. Add the native dependency and verify that it is available in both the development environment and the live image.
3. Implement connection open/close, root-window discovery, event-mask selection, and error handling.
4. Implement a narrow event loop for `MapRequest`, `ConfigureRequest`, `UnmapNotify`, and `DestroyNotify`.
5. Keep the WM in a separate JVM process from Swing applications.
6. Add integration tests that run against a disposable X server such as Xvfb where practical.
7. Add explicit handling for native resource lifetime, architecture assumptions, and shutdown.

**Exit criteria:** The Java process can claim the root-window WM role, observe client lifecycle events, and manage a controlled test client without crashing.

### M4 — Implement the minimum usable floating WM

**Goal:** Manage ordinary Swing windows predictably.

1. Apply the existing deterministic floating layout to actual X11 client windows.
2. Implement focus and stacking behavior.
3. Send close requests using the appropriate client protocol instead of terminating clients blindly.
4. Handle transient/dialog windows, override-redirect windows, and basic popup behavior.
5. Add the minimum ICCCM/EWMH properties needed by Swing/AWT and common X11 tools.
6. Define behavior for maximization, fullscreen, and screen-boundary changes.
7. Test with more than one Swing application and at least one ordinary non-Java X11 client.

**Exit criteria:** Representative Swing applications can open, move, resize, focus, show dialogs, and close under the Java WM in a controlled Xorg/Xvfb environment.

### M5 — Integrate the WM and applications into the image

**Goal:** Turn the prototype into the first end-to-end DazeOS desktop session.

1. Launch the Java WM and applications as separate processes.
2. Define startup ordering, process supervision, clean shutdown, and recovery after a process exit.
3. Add a small session manifest or launcher configuration rather than hard-coding every application in the shell script.
4. Ensure logs are accessible in the live environment and useful for diagnosing X11/native failures.
5. Rebuild the ISO and repeat BIOS, UEFI, QEMU, Xorg, and Swing smoke tests.

**Exit criteria:** A booted image starts a usable Java-based session without manual process orchestration.

### M6 — Compatibility, security, and release hardening

**Goal:** Establish whether the prototype can be maintained and tested as a real distribution experiment.

- Pin and document the supported Java baseline and correct documentation inconsistencies.
- Test fonts, HiDPI scaling, keyboard layouts, focus/modality, clipboard behavior, and representative Swing/AWT applications.
- Evaluate multi-monitor behavior, graphics drivers, WLAN firmware, audio, suspend/resume, and USB boot on representative hardware.
- Define Debian security-update handling, dependency update policy, image signing, artifact provenance, and rollback/recovery.
- Add reproducible-build checks and a release manifest containing image version, package inputs, checksum, and test results.
- Decide whether JNA/libX11 remains appropriate or whether FFM or JNI/XCB is justified.
- Reassess Wayland only after the X11 desktop model and compatibility requirements are understood.

**Exit criteria:** A documented release process exists, supported hardware and software boundaries are explicit, and the image can be rebuilt and evaluated by another contributor.

## Deferred by design

The following are intentionally outside the first bootable prototype:

- replacing the Linux kernel or Debian low-level userland
- a Wayland compositor
- compositing effects and server-side window decorations
- reparenting windows
- a full desktop environment and application suite
- persistence and installation to disk
- Secure Boot signing
- broad hardware certification
- automatic runtime package updates

These items may become future projects, but they must not obscure the immediate goals of a reproducible image and a small, testable Java/X11 desktop.

## Working agreement for status updates

- A source file or build script is not evidence that its runtime behavior works.
- A successful ISO build is not evidence of BIOS, UEFI, hardware, or Swing compatibility.
- Every completed milestone should record the command, environment, artifact, and observed result.
- When a test is blocked, record the exact error and the next diagnostic action instead of marking the milestone complete.

## Related documentation

- [`README.md`](README.md) — concise project overview and current limitations
- [`CONCEPT.md`](CONCEPT.md) — architecture, decisions, alternatives, and risks
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — development environment, build commands, and validation procedure
- [`java-wm/README.md`](java-wm/README.md) — Java window-manager prototype scope and limitations

