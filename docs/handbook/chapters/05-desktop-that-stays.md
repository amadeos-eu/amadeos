# 5. A Desktop That Stays

Many desktops are redesigned every few years: buttons move, menus disappear, familiar ways of working stop working. amadeOS takes the opposite path. Its desktop follows a design that has proven itself for three decades, and it is meant to stay that way.

## Where the look comes from

The **Common Desktop Environment** (CDE) was created in the early 1990s by HP, IBM, Sun and Novell, who agreed on one common desktop for their Unix workstations. For about ten years it was the standard desktop of professional Unix systems such as Solaris, HP-UX and AIX, used in engineering offices, laboratories, banks and universities. In 2012 its source code was released as free software.

CDE was designed for people who work at a computer all day. It is calm, clear and predictable:

- **The Front Panel** at the bottom of the screen holds a clock, a calendar, the most-used programs and the workspace switch. Small arrows above the buttons open *drawers* with more programs.
- **Four workspaces**, *One* to *Four*, each in its own colour, keep the windows of different tasks apart.
- **Windows** have solid frames with three-dimensional edges in the Motif style, a title bar and buttons to minimise and maximise.
- **The Style Manager** changes colours, fonts, backdrop, keyboard, mouse, windows and screen saver in one place.
- **Palettes** colour the whole desktop at once, with matching light and shadow tones.

## What amadeOS keeps, and what it changes

amadeOS reproduces this desktop faithfully: the layout of the Front Panel and its drawers, the workspace switch, the window frames, the controls of the Style Manager (called Settings in amadeOS), the palettes and the original CDE backdrops. If you have used CDE, you will feel at home at once.

It is not a museum piece, though. Under the familiar surface amadeOS is a new program, written in Java, and adds what a desktop needs today:

| | CDE in the 1990s | amadeOS |
|---|---|---|
| Written in | C with the Motif toolkit | Java with Swing |
| Drawers | Configured by hand | Filled automatically from the installed applications |
| Mail | Mostly local mailboxes | IMAP with folders, several accounts, safe display of HTML mail |
| Calendar | Its own server | A plain iCalendar file |
| Network | Not part of the desktop | Network status in the Front Panel |
| Fonts | Bitmap fonts | Smooth, scalable fonts |

!!! cde "CDE heritage"
    Boxes like this one appear wherever an amadeOS part follows a CDE program: the login screen follows `dtlogin`, the window manager `dtwm`, Settings `dtstyle`, the Mailer `dtmail`, the Calendar `dtcm`, the Print Manager `dtprintinfo`, the screen saver `dtscreen`. Appendix C lists them all.

## Why timeless?

**What you learn stays valid.** The way you work with amadeOS today is the way you will work with it in ten years. Time spent learning the system is not lost with the next update.

**Less distraction.** There are no animations, no transparent windows, no blur and no notifications competing for attention. The desktop gets out of the way of your work. amadeOS leaves out such effects on purpose; they are not missing features.

**It runs on modest hardware.** A desktop without heavy effects needs no expensive graphics card, so older computers stay useful for longer.

**Clarity.** Every element has a clear edge, a clear state and a clear purpose. Pressed buttons look pressed, the active window is clearly marked, and the colours of the palette tell the workspaces apart.

A desktop that stays does not mean a desktop that stands still. amadeOS gets new applications, new settings and fixes all the time. What it avoids is change for its own sake.
