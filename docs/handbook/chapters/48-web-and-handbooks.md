# 48. Web Browser and Handbooks

## Firefox

The web browser of amadeOS is **Firefox ESR**, the long-term version of Firefox that receives security updates for a long time without changing its face every few weeks. It is installed in the five languages of amadeOS.

Start it from the Mail & Internet drawer of the Front Panel, or by clicking a web link in any program. The Mailer and the Documentation Viewer hand web links to Firefox; the Mailer shows you first where a link really goes.

amadeOS sets Firefox up for privacy from the first start:

- **No telemetry** and no studies: Firefox sends no usage data to Mozilla.
- **No sponsored content**: no sponsored tiles and suggestions on the start page or in the address bar, no Pocket, no recommendations.
- **Ecosia** is the search engine, a search engine from Berlin that plants trees with its income. Any other can be chosen in the settings.
- **uBlock Origin** is installed, which blocks advertising and trackers. It can be switched off for single sites with its icon.

These are defaults. Everything can be changed in Firefox's settings, and the changes are yours.

!!! sovereignty "Your data"
    Firefox is developed by Mozilla, which belongs to a non-profit foundation, under a free licence, and its engine, Gecko, is one of the last that does not come from one of the large technology companies.

??? hood "Under the hood"
    The defaults are a Firefox *policy* file, `/usr/share/firefox-esr/distribution/policies.json`, which applies to every user of the computer.

## The Documentation Viewer

The **Documentation Viewer** shows the documentation that comes with the installed programs, under `/usr/share/doc`, and other local HTML and text files. It starts in a second and needs no network: it loads nothing from the internet, and web links go to Firefox.

Open it from the Help drawer, or with `amade-web file.html`.

![The Documentation Viewer](images/48/documentation-viewer.jpg)

| Key | What it does |
|---|---|
| ++ctrl+l++ | Type an address or a path |
| ++ctrl+o++ | Open a local file |
| ++alt+arrow-left++ / ++alt+arrow-right++ | Back / forward |
| ++alt+home++ | The start page, `/usr/share/doc` |
| ++f5++ | Reload |
| ++ctrl+plus++ / ++ctrl+minus++ / ++ctrl+0++ | Larger / smaller text / normal size |

It shows HTML pages, folders (with their `index.html`, or as a list), text files such as READMEs and changelogs, also when they are compressed (`changelog.Debian.gz`), and pictures. PDF and office files go to their programs.

It has no JavaScript and draws modern layouts (CSS 3) only in part, so the large handbooks open in Firefox instead.

!!! planned "Planned"
    A table of contents of all installed documentation, full-text search, manual pages and bookmarks.

## The handbooks

The **Help** slot of the Front Panel opens this handbook, the *amadeOS User's Handbook*. Its drawer lists:

| Entry | What it is |
|---|---|
| **amadeOS User's Handbook** | This book. It is installed on the computer, so it opens in Firefox without a network. |
| **Game Developer's Handbook** | How the games of chapter 49 are made, and how to write your own with the amade game engine. |
| **Documentation Viewer** | The documentation of the installed packages, see above. |

The handbook is also on the web, at `https://datazuul.github.io/amadeos/`, always in its newest version. In Firefox, ++ctrl+f++ searches the page and the search box at the top searches the whole book.
