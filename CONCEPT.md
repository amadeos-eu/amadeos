# DazeOS concept

DazeOS (Digital Autonomy, Zero Lock-in, Empowerment) is a free, European, Java-centred desktop operating system concept. The initial technical target is a bootable x86-64 Debian-based USB image that can run on ordinary BIOS and UEFI hardware. The project is intended to provide an understandable, reproducible desktop stack with Java as the principal application and desktop-extension language, without claiming that every operating-system component must be written in Java.

## Initial target and boundaries

The first usable system is deliberately modest:

- Debian Stable Minimal as the base userland
- an x86-64 live image for USB, with BIOS and UEFI boot paths
- Xorg/X11 as the initial display stack
- a Java-based, non-reparenting, floating window manager
- Swing applications as the first-class example application model

The kernel, device drivers, firmware interfaces, libc, boot loader, and most low-level utilities remain established native software. DazeOS is a distribution and desktop-system experiment first; replacing all of Linux is not an initial requirement.

## Architectural choices

### Kernel: Linux first, not a new kernel

A new kernel would provide maximum control over the design, but would also require drivers, scheduling, memory management, filesystems, networking, security mechanisms, power management, suspend/resume, firmware support, and a large testing effort. That scope would obscure the Java desktop goal and make usable hardware support unlikely.

The chosen direction is therefore Linux, supplied by Debian. A new kernel is not part of the initial plan. Kernel replacement could only be a later research project with a separate justification, compatibility contract, and hardware-support budget.

### Distribution base: Debian Stable Minimal

Debian Stable Minimal is the selected base because it offers a broad x86-64 hardware ecosystem, mature package management, security updates, documentation, and a practical route to a reproducible live image. A minimal installation keeps the initial image understandable and avoids inheriting an unnecessary desktop environment.

The alternatives were considered as follows:

- **Alpine Linux:** small and security-conscious, but its musl libc and ecosystem introduce additional compatibility work for Java, native libraries, desktop software, and third-party binaries.
- **Buildroot:** excellent for producing a small appliance image with a controlled root filesystem, but it is not a general-purpose distribution and requires more ownership of package selection, upgrades, and maintenance. It remains a possible later image-building approach, not the initial base.
- **Yocto:** powerful for product-grade, reproducible embedded distributions, but its metadata, layers, and maintenance model are disproportionate for the first desktop prototype.
- **Tiny Core:** very small and useful for experiments, but its packaging and persistence model do not provide the preferred foundation for a maintained Java desktop system.

The decision is Debian Stable Minimal. Image construction is a separate decision from the base distribution: the initial pipeline is expected to use Debian-oriented live-build tooling, while Buildroot is retained as a possible future experiment rather than a simultaneous requirement.

### Display protocol and server: Xorg/X11 first

The initial display stack is Xorg. The terms are related but not interchangeable:

- **X11** is the version 11 network-transparent window-system protocol and its API conventions.
- **Xorg** is the commonly used open-source server implementation of that protocol on Linux.
- **X server** is the server process that owns the display, input devices, and screen resources.
- **X client** is an application or window manager that connects to the server; it need not run on the same machine.
- **Xlib** and **XCB** are client-side programming interfaces for X11. They are not alternative display servers.

Xorg was selected for the first implementation because Java/AWT/Swing integration, diagnostic tools, remote-display concepts, and the window-manager protocol are well understood. The cost is an older, more complex security model and dependence on a legacy protocol family.

Wayland was considered as the longer-term direction. It has a simpler modern compositor model and avoids several X11-era trust and indirection problems, but a Wayland compositor is also responsible for more desktop integration, input handling, rendering, protocols, and compatibility decisions. A Java window manager would therefore become a Java compositor and would require a different native integration strategy. Wayland is not rejected; it is deferred until the X11 prototype establishes the desktop model and its requirements.

### Window manager: Java, non-reparenting, floating

The planned window manager is written in Java and initially uses X11 window-manager protocols. It will be a **non-reparenting** window manager: client windows remain direct children of the root window rather than being placed inside additional frame windows. This reduces frame bookkeeping and makes the initial implementation easier to inspect, but it also limits decoration and may expose more client-specific behavior than a reparenting manager.

**Reparenting** window managers insert a frame or decoration window around each client window. That supports traditional borders, title bars, and richer decoration, but adds coordinate translation, event routing, lifecycle handling, and more failure cases. Reparenting remains a possible later feature if the minimal model proves insufficient.

The initial layout policy is **floating**, not tiling. Floating permits ordinary Swing applications and existing desktop expectations with the least policy imposed on users. Tiling can improve keyboard-driven workflows and space usage, but it introduces layout policy, resizing rules, transient-window handling, and compatibility questions. Tiling may be offered later as an optional policy rather than defining the first desktop.

The window manager is not intended to replace the X server, the kernel, or the Java runtime. It is an X11 client with window-manager responsibilities: selecting the relevant root-window events, managing client lifecycle and focus, applying placement and stacking policy, and eventually providing minimal user-facing controls.

### Java desktop toolkit

Swing and AWT are the first application target because they are part of the established Java desktop ecosystem and provide a concrete way to demonstrate a Java-centred desktop. Swing supplies the application widgets; AWT supplies desktop integration and the native peer/event boundary used by Java desktop applications. The project must not assume that every Swing application behaves identically: heavyweight AWT peers, popups, focus, modality, HiDPI scaling, and native dialogs all affect window-management behavior.

The Java window manager is separate from Swing. Swing does not manage top-level X windows, and a window manager does not render Swing widgets. Keeping that boundary explicit makes failures easier to classify and allows non-Swing X clients to remain part of the compatibility target.

### Native X11 access from Java

The initial native-access choice is deliberately pragmatic:

- **JNA with libX11** is the easiest prototype route. It avoids writing a large JNI library and makes X11 calls visible in Java, at the cost of runtime marshalling overhead, dependency on libX11, and less control over low-level details.
- **FFM** (the Foreign Function and Memory API) is the modern JDK-native alternative. It can remove a separate JNA dependency, but its availability and finalized API shape depend on the selected Java baseline, and the bindings still require careful native layouts and lifetime management.
- **JNI with XCB** offers explicit native bindings and XCB's asynchronous, typed request model, but requires a maintained native library, build integration, ABI handling, and more C code.

The first prototype is expected to prefer JNA/libX11 for speed of learning and observability. FFM or JNI/XCB can be evaluated once the protocol surface is known and performance, packaging, or dependency constraints justify the migration. This is an implementation preference, not a claim that JNA is the final ABI.

## Image and delivery model

The delivery target is a live ISO that can be written to a USB device and booted on x86-64 systems. BIOS and UEFI support must be tested separately; a successful ISO build alone does not prove either boot path. Persistence, installation to disk, secure boot signing, suspend/resume, and broad hardware certification are outside the first milestone unless explicitly added later.

The initial image pipeline is planned around Debian live-build and related Debian tooling. live-build is aligned with the selected distribution and provides established live filesystem, bootloader, and package-customization concepts. Buildroot remains useful for a future highly controlled appliance-style image, but adopting it now would duplicate distribution and package-maintenance responsibilities. The build should eventually be reproducible from a documented Debian environment, with explicit package lists and version/update policy.

## Risks and decisions still requiring validation

- **Updates and security:** Debian security updates, the JDK, JNA/native libraries, Xorg, and DazeOS code all have separate release cadences. A defined update channel, signed artifacts, rollback/recovery story, and vulnerability-response process are still required; a live image is not automatically secure merely because its base is Debian.
- **Hardware:** Linux support is broad but not universal. GPU acceleration, input devices, wireless firmware, suspend/resume, unusual displays, BIOS/UEFI differences, and proprietary firmware can affect the desktop. Hardware testing must include real BIOS and UEFI machines, not only a virtual machine.
- **Java compatibility:** The selected JDK version affects Swing/AWT behavior, FFM availability, fonts, HiDPI rendering, module access, and native-library loading. The supported Java baseline must be pinned and tested with representative Swing applications.
- **X11 behavior:** ICCCM/EWMH conventions, transient windows, focus, override-redirect windows, client quirks, multiple monitors, and compositing can expose gaps in a minimal window manager. Non-reparenting behavior must be validated against both Swing and ordinary X clients.
- **Native boundaries:** JNA/libX11, FFM, or JNI/XCB can fail through ABI mismatches, pointer/lifetime errors, missing libraries, and architecture assumptions. Native access must be isolated and tested on the supported x86-64 image.
- **WSL2 limitations:** WSL2 is suitable for source work and early build experiments, but it is not a substitute for booting the produced image on hardware. USB boot, firmware behavior, graphics acceleration, and some device tests require a VM or physical system.

These risks make the first goal a small, inspectable booting prototype rather than a claim of production readiness. Decisions above describe the current direction; implementation evidence and compatibility tests may revise them in later milestones.

