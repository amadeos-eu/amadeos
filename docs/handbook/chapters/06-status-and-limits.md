# 6. Status and Limits

amadeOS 1.0.0 is the **first release**, and development goes on. This chapter says honestly what works, what has been tested and what has not, so you can decide whether amadeOS fits your needs today.

## What works

| Area | State |
|---|---|
| Live system | A bootable image for USB sticks, for PCs with BIOS or UEFI. Tested in the QEMU virtual machine. |
| Installation | The assistant *Install amadeOS* installs the system onto a hard disk, on a whole disk or on a free partition. A whole-disk installation with BIOS boots into the desktop in QEMU. |
| Login | Login screen with language and time zone, password check through PAM. |
| Desktop | Window manager with Motif frames, four workspaces, desktop menu, Front Panel with drawers, screen lock and screen saver. |
| Settings | Colour, text size, backdrop, keyboard, mouse, beep, screen, windows and clipboard. |
| Languages | English, Deutsch, Français, Español, Italiano. |
| Network | Ethernet by itself; wireless networks through a text dialog. |
| Printing | Network and USB printers without drivers (IPP Everywhere, AirPrint); Print Manager for printers and jobs. |
| Applications | Text Editor, Mailer, Calendar, File Manager, Image Scan, Fractals, documentation viewer and 17 games work; WritePad, Audio Station and Video Player are at an early stage. |
| Web | Firefox ESR, preconfigured for privacy. |
| Updates | Debian's updates and, from the amadeOS package repository, new versions of the desktop, the applications and the games (chapter 52). |

## What is not tested yet

- **Real hardware.** So far amadeOS has been tested mostly in virtual machines. Graphics acceleration, wireless firmware, sound, suspend and resume, several monitors and booting from a USB stick on many different computers still need testing. Reports from your own computer are very welcome.
- **The UEFI installation** and the installation **next to Windows** are being tested in QEMU, not yet on a real machine.

## What amadeOS does not do yet

!!! planned "Planned"
    - **Disk encryption** and a separate home partition in the installer (M14).
    - **The Startup control of Settings.**
    - **Signed images** and a release manifest that lists every package, with a documented release process (M12).

## Limits by design

Some things amadeOS leaves out on purpose:

- **X11, not Wayland.** amadeOS uses the Xorg display server. Wayland may be considered later, once the desktop is complete on X11.
- **No visual effects.** No transparency, shadows, blur or animations; see chapter 5.
- **The live system forgets.** Changes you make in the live system from the USB stick are lost at the next start. To keep your work, install amadeOS (chapter 14).
- **No automatic updates behind your back.** amadeOS tells you about updates and installs them when you ask (chapter 52). Only security updates can be installed automatically, and only once you turn that on.

## Should you use amadeOS today?

amadeOS is ready to **try**: start the live system, look around, use the applications, report what you find. It is a good system for a spare computer, for learning, and for anyone who wants to help shape it.

It is **not yet** the system for a computer whose data you cannot afford to lose, or for work that must not be interrupted. Keep a backup, and wait until amadeOS has been tested on more hardware before you rely on it.

The current state is always in the [ROADMAP](https://github.com/datazuul/amadeos/blob/main/ROADMAP.md), and bugs and ideas go to the [issue tracker](https://github.com/datazuul/amadeos/issues).
