# 2. Why Another Linux Distribution?

There are hundreds of Linux distributions already. Why one more? This chapter answers in two steps: what a distribution is, and what amadeOS adds that the others do not have.

## What a distribution is

Linux itself is only the *kernel*: the part of the system that talks to the hardware. To get a computer you can work with, you need much more: programs to start the system, libraries, a graphical display, a desktop, applications, a way to install and update all of it. A **distribution** puts these thousands of parts together, tests them with each other and delivers them as one system.

Most distributions differ in two things: *how* they deliver software (their package system and release rhythm) and *which desktop* they bring. Many share the same desktops, mostly GNOME and KDE Plasma.

## What amadeOS keeps

amadeOS deliberately does **not** reinvent the lower layers. It keeps:

| Layer | amadeOS uses | Why |
|---|---|---|
| Kernel | Linux, as Debian ships it | Broad hardware support, security fixes, decades of work. |
| Base system and packages | Debian *trixie* (13), minimal | A community project with a long record of stable releases and security updates; `apt` and `.deb` packages. |
| Display | Xorg (X11) | Well understood, works with every Java program and with other X11 programs. |
| Web browser | Firefox ESR from Debian | A free browser with long-term support and security updates. |
| Sound, network, printing | PipeWire, NetworkManager, CUPS | The standard services of a Linux desktop. |

So amadeOS is not a new platform you have to trust from scratch. Underneath, it is Debian. A program packaged for Debian generally installs on amadeOS too, and Debian's security team looks after the base system.

## What amadeOS adds

On top of that foundation, amadeOS brings a **desktop of its own**, written from scratch:

- a login screen (the display manager),
- a window manager that draws the window frames,
- the Front Panel, with clock, calendar, workspaces and drawers of applications,
- the Style Manager for colours, backdrops, keyboard, mouse and screen saver,
- tools to look after the system: log viewer, system information, Print Manager, installer,
- and a family of everyday applications: File Manager, Text Editor, WritePad, Mailer, Calendar, Audio Station, Video Player, Image Scan, Fractals and a collection of games.

All of these share one look, one set of colours and one language setting, and they are written in one programming language, Java. That combination is what no other distribution offers, and it cannot simply be installed on top of another system without its defaults and its integration.

## Why not "just a desktop for Debian"?

In a way, amadeOS *is* a desktop for Debian: every part of it is an ordinary Debian package, and Part VII shows how they fit together. But a desktop alone does not make a usable system. Someone has to choose the firmware for common network cards, set up sound and printing, preconfigure the browser for privacy, provide an installer and test that everything works together on a USB stick and on a hard disk. That is the work of a distribution, and amadeOS does it once for everybody.

## How amadeOS compares

A rough comparison with a typical desktop distribution based on Debian or Ubuntu with GNOME:

| | Typical GNOME distribution | amadeOS |
|---|---|---|
| Base | Debian or Ubuntu | Debian |
| Desktop written in | C, JavaScript and more | Java |
| Look | Modern, changes with major versions | Classic CDE, kept stable on purpose |
| Applications | GNOME applications, mixed toolkits | amadeOS applications in one style, plus any Linux program |
| Licence of the desktop | mostly GPL | EUPL-1.2 |
| Maturity | Used by millions | Pre-release (see chapter 6) |

The last row matters: amadeOS is young. If you need a system for important work today, chapter 6 tells you honestly what is ready and what is not.

!!! switching "Coming from Windows or macOS"
    You do not need to know any of the layers in the first table. You will mostly meet the top of the stack: the Front Panel, the windows and the applications, which Parts III to V explain step by step.
