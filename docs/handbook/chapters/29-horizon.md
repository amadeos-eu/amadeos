# 29. The Horizon Look

amadeOS has two looks for the whole desktop. **Classic** is the CDE desktop this handbook mostly shows: the Front Panel at the bottom, Motif window frames and the palettes of chapter 31. **Horizon** is a second, modern look: a slim bar along the top of the screen, a dock at the bottom, flat window frames with rounded corners, and dark or light colours with an accent colour of your choice.

Both looks run the same programs, the same window manager and the same settings. You can switch back and forth at any time; nothing is lost.

![The Horizon look](images/29/horizon-desktop.jpg)

## Switching the look

Open **Settings → Desktop look** (the first page of the *Appearance* group).

![The Desktop look page](images/29/settings-look.jpg)

1. Click the picture **Classic** or **Horizon**.
2. For Horizon, choose the **Scheme**, *Dark* or *Light*, and an **Accent colour**: teal, violet, amber, red, green or blue. The picture shows how it will look.
3. Leave **Use the Horizon background picture** ticked to get the matching background (*horizon-dark.png* or *horizon-light.png*); clear it to keep your own backdrop.
4. Under **Dock**, choose the **Icon size** (*Small*, *Medium* or *Large*) and whether the dock shows the program drawers and the Downloads and Documents folders.
5. Click **Apply**.

![Horizon with the Light scheme and the violet accent](images/29/horizon-light.jpg)

The window frames change at once, the Front Panel gives way to the top bar and the dock (or the other way round), and the open amadeOS applications take the new colours. You do not need to log out. Your choices are kept: switch back to Classic and you get your last palette again; switch to Horizon and you get your last scheme and accent colour.

## The top bar

![The system menu of the top bar](images/29/system-menu.jpg)

From left to right the top bar holds:

| Part | What it does |
|---|---|
| **The ring** | Opens the system menu: *About this computer*, **Programs** (every installed program, sorted like the drawers of the Front Panel), *Files*, *Settings*, *Software*, *Task Manager*, *Lock screen* and *Log out or shut down…* (the Exit dialog of chapter 26). |
| **The program name** | The name of the program you are working in, in bold, or *Desktop*. A click opens a small menu to minimise or close its window. |
| **The four dots** | The workspaces; the current one is the wider dot in the accent colour. Click a dot to switch, hold the mouse over it to see the workspace's name. |
| **The status cells** | Network, sound, battery, Bluetooth, notifications, waiting updates and the camera light: the same cells as in the Front Panel (chapter 27), chosen under *Settings → Front Panel* (chapter 37). |
| **The clock** | Weekday, date and time. A click opens the Calendar. |

Windows stay below the top bar: a maximised window fills the screen under it, and a window cannot be dragged under it.

## The dock

![The dock](images/29/dock.jpg)

The dock floats at the bottom of the screen. Thin lines divide it into three parts:

| Part | What it holds |
|---|---|
| **Programs** | Your favourite programs, then the programs that are running without being favourites. A dot under an icon means the program is running; a ring means all its windows are minimised. |
| **Drawers** | The groups of the Front Panel's drawers: Text & Office, Mail & Internet, Sound & Video, Graphics, Games and Tools. A small triangle marks a drawer. |
| **Folders and Trash** | Downloads and Documents, then the Trash. |

**Programs.** A click on a program that is not running starts it. A click on a running program brings its window to the front; a click on the program you are working in minimises its window, or, with several windows, goes on to the next one. A click with the middle mouse button opens a new window. The right mouse button opens a menu with the program's windows, *New window*, *Keep in dock* or *Remove from dock*, and *Close* (or *Close all windows*).

To add a program to the dock, start it, then choose *Keep in dock* from its menu; it stays after you close it. *Remove from dock* takes it out again. The first favourites are Files, Firefox, Mail, Calendar, WritePad, Audio Station, Terminal and Software, those of them that are installed.

**Minimised windows** go into their program's icon in the dock, not onto the desktop: click the icon, or choose the window from its menu, to bring it back. In the Classic look they become desktop icons again.

![A drawer of the dock](images/29/dock-drawer.jpg)

**Drawers.** A click on a drawer opens the installed programs of its group above the dock; a click on a program starts it. Programs you install appear in their drawer right away.

![The Downloads folder in the dock](images/29/dock-folder.jpg)

**Folders.** A click on Downloads or Documents shows the ten newest files of the folder; a click on a file opens it in its program, *Open folder* opens the folder in Files. A click on the **Trash** opens it in Files.

Windows stay above the dock, as they stay below the top bar: a maximised window fills the space between the two.

## The window frames

![A Horizon window frame](images/29/frame.jpg)

A Horizon frame has a flat title bar in the window's own colour. A thin line in the accent colour runs along the top of the window you are working in; the other windows show their title in grey.

- **The program icon** at the left of the title bar opens the window menu (Restore, Minimise, Maximise, Lower, Close), as the menu button of a classic frame does; a double click on it closes the window.
- **The three symbols at the right** minimise, maximise and close the window. Close turns coral when the mouse is on it.
- **Drag** the title bar to move the window, and drag the thin edge around it to resize it, as in chapter 23.

The corners are rounded with the X Shape extension. Without a compositor the edge is cut pixel by pixel, so the corners look slightly stepped; the soft shadow of other desktops is not there.

!!! planned "Planned: the rest of Horizon"
    Planned next: a **search bar** for programs, settings and files; **desktop widgets** (calendar, to-dos, a photo, a clock); folder icons on the desktop; dragging programs within the dock to reorder them; a flat look for the amadeOS applications and a Horizon icon set. Until then, the amadeOS applications keep their Motif buttons in Horizon's colours.

!!! info "Under the hood"
    The look is stored in `~/.config/amadeos/look.conf` (`look=horizon`, `scheme=dark`, `accent=teal`); the classic palette stays in `theme.conf`. The top bar and the dock are the package **amadeos-panel-horizon**, one program; the dock's favourites, icon size and parts are in `~/.config/amadeos/dock.conf`. The dock sets `_AMADEOS_DOCK_TAKES_MINIMIZED` on its window, so the window manager gives minimised windows no desktop icon while it runs. `amadeos-session` starts the panel of the look; when the look changes, the running panel ends with exit code 75 and the session starts the other one (chapter 55). Without amadeos-panel-horizon, the Front Panel stays in both looks.
