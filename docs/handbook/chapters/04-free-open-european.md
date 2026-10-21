# 4. Free, Open and European

amadeOS is free software, it is built on open standards, and it is licensed under a European licence. This chapter explains what each of these means and why it matters to you.

## Free software

*Free* here means freedom, not only price. Free software gives everyone four freedoms:

1. to **run** the program for any purpose,
2. to **study** how it works, because its source code is available,
3. to **share** copies with others,
4. to **improve** it and share the improvements.

All of amadeOS is free software, and so is the Debian system underneath it. No licence fee, no activation, no expiry date, and nobody who can take the software away from you.

## The EUPL: a European licence

The amadeOS desktop and its applications are published under the **European Union Public Licence, version 1.2** (EUPL-1.2). It was written and is published by the European Commission.

What makes the EUPL special:

- **It is valid in all official languages of the EU.** There are 23 language versions, and all of them have the same legal value. You can read the licence of amadeOS in your own language, not only in American legal English.
- **It is written for European law.** It was drafted to fit the copyright and contract law of the EU member states.
- **It is a copyleft licence.** Whoever distributes a changed version of amadeOS must publish the changed source code under the EUPL too. Improvements stay free.
- **It is compatible.** The EUPL names a list of other licences (among them the GPL, the LGPL and the MPL) under which code may be combined with it, so amadeOS can work together with the rest of the free-software world.

The text of the licence, in every language, is at [interoperable-europe.ec.europa.eu](https://interoperable-europe.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

## Other licences in amadeOS

amadeOS is an *aggregation*: it contains many packages, and each keeps its own licence. A few examples:

| Part | Licence |
|---|---|
| amadeOS desktop, applications, games, this handbook | EUPL-1.2 |
| Linux kernel | GPL-2.0 |
| Debian base system | mostly GPL, LGPL, BSD and MIT |
| Firefox ESR | MPL-2.0 |
| NsCDE icon theme (package `nscde-icon-theme`) | GPL-3.0 |
| Original CDE backdrops (package `amadeos-backdrops-cde`) | LGPL-2+ |

On an installed system, the licence of every package is in `/usr/share/doc/<package>/copyright`.

## Open standards instead of lock-in

Free code alone is not enough; your *data* must be free too. amadeOS therefore uses open, documented formats and protocols wherever it can:

| For | amadeOS uses |
|---|---|
| Appointments | iCalendar (`.ics`), readable by every calendar program |
| Mail | IMAP and SMTP, so any mail provider works |
| Documents | plain text, and OpenDocument (`.odt`) as WritePad's own format |
| Pictures | PNG, JPEG, TIFF |
| Applications in the menus | Freedesktop `.desktop` entries |
| Windows and workspaces | the X11 conventions ICCCM and EWMH |
| Software | Debian packages (`.deb`) |

If you ever leave amadeOS, your data comes with you, and other programs can read it.

!!! planned "Planned"
    WritePad, the word processor, opens and saves OpenDocument, Word and RTF files only once its import and export steps are done; today it lays out and prints text on pages.

## European

amadeOS is developed in Europe, under a European licence, with the European idea of digital sovereignty in mind: public bodies, companies and citizens should be able to choose their software freely and not depend on a handful of vendors from elsewhere. Its desktop speaks five European languages from the start: English, Deutsch, Français, Español and Italiano.

European does not mean closed. amadeOS is open to anyone in the world who wants to use it, study it or help.
