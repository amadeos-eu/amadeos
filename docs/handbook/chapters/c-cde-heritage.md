# C. CDE Heritage

amadeOS follows the **Common Desktop Environment** (CDE), the desktop of the large Unix workstations of the 1990s from HP, IBM, Sun and others, and since 2012 free software. This appendix lists which part of amadeOS follows which part of CDE, and where amadeOS does it differently. Chapter 5 explains why amadeOS keeps this desktop.

| amadeOS | In CDE | What amadeOS does differently | Chapter |
|---|---|---|---|
| Login screen (`amadeos-dm`) | `dtlogin` | Language and session are fields, not hidden in an *Options* menu; keyboard layout and time zone are chosen there too. | 20 |
| Window frames (`amadeos-wm`) | `dtwm` | A close button on the right; no *Move* and *Size* in the window menu. | 23 |
| Workspaces | `dtwm` workspaces | Four workspaces, renamed as in CDE by clicking the current one's button; each can have its own backdrop. Their number is fixed. | 24, 32 |
| Workspace Menu | The `dtwm` root menu | Built from the installed programs instead of a hand-edited `dtwmrc`. | 24 |
| Front Panel (`amadeos-panel-cde`) | The Front Panel | Drawers (CDE's *subpanels*) fill themselves from the installed programs. New: the Games drawer, the status slot, the language button. | 22 |
| Lock and EXIT | Lock and EXIT of the Front Panel | ++super+l++ locks; EXIT also offers *Reboot* and *Shut Down*. | 26 |
| Settings (`amadeos-settings`) | `dtstyle` (Style Manager) | The same controls, in a sidebar with a search; *View → Compact* shows CDE's row of buttons. *Clipboard* is new; *Startup* is still to come. | Part IV |
| Palettes and workspace colours | `dtstyle` palettes | The original palettes such as *Brocade* and *Desert*, and new ones. | 31 |
| Backdrops | The CDE backdrops | The 26 original patterns, plus pictures and plain colours. | 32 |
| Screen saver and lock | `dtscreen`, `dtsession` lock | Modules such as Qix and Swarm. | 34 |
| Icons | The CDE icons | The NsCDE icon theme, in the style of CDE. | 31 |
| Application Manager | `dtappmgr` | Lists all installed programs by kind, by itself. | 22 |
| File Manager (`amade-files`) | `dtfile` | A folder tree, or two panels side by side; the path bar of CDE above. | 41 |
| Text Editor (`amade-pad`) | `dtpad` | Tabs for several files. | 42 |
| Mailer (`amade-mail`) | `dtmail` | Folders of the mail server in a column, several accounts, HTML mail shown safely; CDE's letters `N`, `A`, `!`, `@` in the list. | 44 |
| Calendar (`amade-calendar`) | `dtcm` | Stored as iCalendar, the standard format of other calendars. | 45 |
| Print Manager (`amadeos-print`) | `dtprintinfo` | Talks to CUPS, the print system of Linux. | 27, 54 |
| Terminal | `dtterm` | `xterm`, the terminal of X11. | 22 |
| This handbook | The Help Viewer `dthelpview` | Web pages, opened in Firefox, also without a network. | 48 |
| Session Diagnostics & Logs | The session log `~/.dt/errorlog` | One window for the logs of the session, the programs and the system. | 57 |

## What is new

Some parts of amadeOS have no model in CDE, because their tasks did not exist on a 1990s workstation or were solved elsewhere: the network and updates cells, **Software** for installing programs, the **clipboard history**, the **installer**, **WritePad** for documents on pages, the **Audio Station** and the **Video Player**, **Image Scan**, the **games**, and the five languages chosen at login.

!!! cde "CDE heritage"
    CDE itself is still alive as free software at <https://sourceforge.net/projects/cdesktopenv/>. amadeOS does not use its code: it is a new desktop written in Java, in CDE's spirit.
