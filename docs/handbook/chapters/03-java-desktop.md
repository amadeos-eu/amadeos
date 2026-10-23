# 3. A Java-Centred Desktop

The most unusual thing about amadeOS is invisible on the screen: the whole desktop is written in **Java**. This chapter explains why, what that means for you, and what is still written in other languages.

## One language from the login screen to the editor

On most systems, the parts of the desktop are written in many languages: C for the display server and the window manager, C++, JavaScript, Python or Vala for the panel, the settings and the applications. Each part has its own build system, its own libraries and its own way of drawing on the screen.

In amadeOS, these are all Java programs, built on the same libraries:

| Part | Program |
|---|---|
| Login screen | `amadeos-dm` (display manager and greeter) |
| Window frames, workspaces, desktop menu | `amadeos-wm` (window manager) |
| Front Panel | `amadeos-panel-cde` |
| Settings | `amadeos-settings` |
| Screen saver and screen lock | `amadeos-session` |
| System tools | `amadeos-logviewer`, `amadeos-sysinfo`, `amadeos-print`, the installer |
| Applications and games | `amade-pad`, `amade-mail`, `amade-files`, …, `amade-mines-game`, … |

The applications use the shared library *amade-commons* for their colours, their Motif look and their language, so a change in Settings reaches all of them at once.

## Why Java?

**Understandable.** Java is one of the most widely taught programming languages. Many people who have learned to program can read the source code of the amadeOS desktop. A desktop that more people can read is a desktop that more people can check, fix and improve. That is sovereignty in practice, not only in the licence.

**Safe by design.** Java manages memory itself. A whole class of errors that cause crashes and security holes in C programs (reading past the end of a buffer, using memory after it was freed) cannot happen in Java code.

**Made to last.** Java programs written twenty years ago still run today. The language changes carefully and keeps old programs working, which fits a desktop that is meant to stay.

**Portable.** The amadeOS applications and games are built to run on other systems too, on other Linux distributions and on Windows; the games already do. Your favourite tools are not locked to amadeOS either.

**Swing.** Java comes with a complete toolkit for windows, menus and buttons, *Swing*. amadeOS gives it the look of the Common Desktop Environment and uses it everywhere.

## What is not written in Java

amadeOS does not claim that *everything* must be Java. Some parts are better left to proven native software:

- the **Linux kernel** and the drivers for your hardware,
- the **C library** and the basic tools of the system,
- the **Xorg** display server, which draws on the screen and reads keyboard and mouse,
- the **boot loader** GRUB, systemd, NetworkManager, PipeWire and CUPS,
- the **Java runtime** itself (OpenJDK 25 from Debian),
- **Firefox**, the web browser.

The Java programs talk to these parts through their documented interfaces: the window manager speaks the X11 protocol to Xorg, the Front Panel asks NetworkManager about the network, the Print Manager talks to CUPS.

??? hood "Under the hood"
    The window manager calls the X11 library `libX11` directly from Java, through *JNA* (Java Native Access), and follows the window-manager conventions ICCCM and EWMH. That is why ordinary X11 programs that are not written in Java, such as `xterm` or Firefox, get the same frames and work with the workspaces. Chapter 61 explains this in detail.

## What this means for you

As a user, you notice the Java desktop mostly through its consistency: every window, menu and dialog of amadeOS looks and behaves the same way, follows the same colours and speaks the same language. Programs from other sources (Firefox, LibreOffice, GIMP and so on) work too, with their own look inside the amadeOS window frames.

!!! switching "Coming from Windows or macOS"
    You do not need Java knowledge to use amadeOS, any more than you need to know C to use Windows. The Java runtime is part of the system and is updated with it.
