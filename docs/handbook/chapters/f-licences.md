# F. Licences

amadeOS is free software. This appendix lists the licences of its parts; chapter 4 explains what they mean.

## amadeOS

The desktop, the system tools, the installer, the amade applications and games, the shared libraries `amade-commons` and `amade-game-engine`, and this handbook are published under the **European Union Public Licence, version 1.2** (EUPL-1.2), in every repository at <https://github.com/datazuul>. The text of the licence, in all 23 official languages of the EU, is at [interoperable-europe.ec.europa.eu](https://interoperable-europe.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

## Parts from elsewhere in the image

| Part | Licence |
|---|---|
| The Linux kernel | GPL-2.0 |
| The Debian base system | Mostly GPL, LGPL, BSD and MIT, one licence per package |
| OpenJDK 25, the Java runtime | GPL-2.0 with the Classpath Exception |
| Xorg | MIT and related licences |
| Firefox ESR | MPL-2.0 |
| LibreOffice | MPL-2.0 |
| NsCDE icon theme (`nscde-icon-theme`) | GPL-3.0 |
| The original CDE backdrops (`amadeos-backdrops-cde`) | LGPL-2.0 or later |

## Libraries inside the amadeOS programs

The Java programs of amadeOS carry a few libraries from other free-software projects inside their packages:

| Library | Used by | Licence |
|---|---|---|
| JNA (Java Native Access) | Window manager and desktop, Audio Station, Video Player, Image Scan | LGPL-2.1 or later, or Apache-2.0 |
| dbus-java | The password window of the session | MIT |
| Guice, SLF4J | amade-commons | Apache-2.0, MIT |
| Logback | The amade applications and games, the desktop | EPL-1.0 or LGPL-2.1 |
| Flying Saucer | Mailer, Documentation Viewer, Software | LGPL-2.1 or later |
| jsoup | Mailer, Documentation Viewer | MIT |
| Jakarta Mail, Eclipse Angus Mail | Mailer | EPL-2.0, GPL-2.0 with the Classpath Exception, or EDL-1.0 |
| SnakeYAML | Software | Apache-2.0 |
| JLayer, MP3SPI, JOrbis, VorbisSPI, Tritonus | Audio Station | LGPL-2.1 |
| jFLAC | Audio Station | LGPL-2.1 |
| javasound-aac | Audio Station | Apache-2.0 |
| jaudiotagger | Audio Station | LGPL-2.1 |

## On your computer

Every package names its licence in `/usr/share/doc/<package>/copyright`, for example:

```sh
less /usr/share/doc/firefox-esr/copyright
```

The screenshots in this book show amadeOS and the programs on it; each program keeps its own licence.
