# amadeOS User's Handbook

**Digital Sovereignty starts on your desktop.**

amadeOS is a free operating system for ordinary PCs. It is built on Debian and Linux, and its desktop, from the login screen to the text editor, is written in Java. It has the calm, classic look of the Common Desktop Environment (CDE): a Front Panel at the bottom, four workspaces and windows with solid three-dimensional frames.

This handbook explains why amadeOS exists, how to try and install it, how to work with it every day and how to look after it as an administrator.

## Who this book is for

You use a computer every day, perhaps with Windows or macOS, and you want to know whether amadeOS is for you. You do **not** need to know Linux. Where the book uses a technical word, it explains it, and the glossary (appendix D) will collect them.

You look after computers for others, at home, in a club, a school or an office. The administration part and the boxes marked *Under the hood* tell you which file, setting or command is behind each feature.

You are curious how a desktop works. The last part of the book opens the bonnet: how amadeOS is built from its packages and how you can build it yourself or write a program for it.

## How the book is organised

| Part | What it covers |
|---|---|
| I. Why amadeOS | The ideas behind amadeOS: sovereignty, a Java desktop, free and European, a desktop that stays, and where it stands today. |
| II. Getting amadeOS | What you need, writing a USB stick, starting the live system, installing amadeOS, next to Windows. |
| III. Using the desktop | Logging in, the Front Panel, windows, workspaces, language, network, sound and printing. |
| IV. The Style Manager | Colours, backdrops, keyboard, mouse, beep, screen saver and clipboard. |
| V. The applications | The amadeOS applications and games, one chapter each. |
| VI. Administering amadeOS | Software, updates, users, the session, settings files, troubleshooting and security. |
| VII. Under the hood | How amadeOS is put together, and how to build it or write for it. |

Parts I to VI are written; [the plan of this book](plan.md) lists every chapter that follows.

## Conventions

- Menu paths are written with arrows: *File → Open*.
- Keys look like this: ++super+l++, ++ctrl+q++.
- Commands you type in a terminal are shown in boxes you can copy:

  ```bash
  sudo apt update
  ```

The book uses five kinds of boxes again and again:

!!! planned "Planned"
    Something amadeOS is meant to do but does not do yet, with the milestone of the [ROADMAP](https://github.com/datazuul/amadeos/blob/main/ROADMAP.md) that brings it. When the feature arrives, the box becomes ordinary text.

!!! switching "Coming from Windows or macOS"
    Where to find what you know from another system.

!!! cde "CDE heritage"
    Which part of the Common Desktop Environment a feature follows, and where amadeOS does it differently.

??? hood "Under the hood"
    The file, setting or command behind a feature. Click the title to open it.

!!! sovereignty "Your data"
    Where your data is kept and what goes over the network.

## Which amadeOS this book describes

amadeOS has not had its first release yet. The book follows the `main` branch of the amadeOS repositories and is updated together with them. Chapter 6, [Status and limits](06-status-and-limits.md), says what works today and what does not.

The book is published at <https://datazuul.github.io/amadeos/>. On amadeOS itself it is installed as the package `amadeos-handbook`, and *Help → amadeOS User's Handbook* in the Front Panel opens it without a network.

The text of the book is under the [EUPL-1.2](https://github.com/datazuul/amadeos/blob/main/LICENSE), like amadeOS. Corrections and suggestions are welcome as [issues](https://github.com/datazuul/amadeos/issues) or pull requests; every page has an edit button at the top.
