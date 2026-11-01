# 29. The Horizon Look

amadeOS has two looks for the whole desktop. **Classic** is the CDE desktop this handbook mostly shows: the Front Panel at the bottom, Motif window frames and the palettes of chapter 31. **Horizon** is a second, modern look: a slim bar along the top of the screen, flat window frames with rounded corners, and dark or light colours with an accent colour of your choice.

Both looks run the same programs, the same window manager and the same settings. You can switch back and forth at any time; nothing is lost.

![The Horizon look](images/29/horizon-desktop.jpg)

## Switching the look

Open **Settings → Desktop look** (the first page of the *Appearance* group).

![The Desktop look page](images/29/settings-look.jpg)

1. Click the picture **Classic** or **Horizon**.
2. For Horizon, choose the **Scheme**, *Dark* or *Light*, and an **Accent colour**: teal, violet, amber, red, green or blue. The picture shows how it will look.
3. Leave **Use the Horizon background picture** ticked to get the matching background (*horizon-dark.png* or *horizon-light.png*); clear it to keep your own backdrop.
4. Click **Apply**.

![Horizon with the Light scheme and the violet accent](images/29/horizon-light.jpg)

The window frames change at once, the Front Panel gives way to the top bar (or the other way round), and the open amadeOS applications take the new colours. You do not need to log out. Your choices are kept: switch back to Classic and you get your last palette again; switch to Horizon and you get your last scheme and accent colour.

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

## The window frames

![A Horizon window frame](images/29/frame.jpg)

A Horizon frame has a flat title bar in the window's own colour. A thin line in the accent colour runs along the top of the window you are working in; the other windows show their title in grey.

- **The program icon** at the left of the title bar opens the window menu (Restore, Minimise, Maximise, Lower, Close), as the menu button of a classic frame does; a double click on it closes the window.
- **The three symbols at the right** minimise, maximise and close the window. Close turns coral when the mouse is on it.
- **Drag** the title bar to move the window, and drag the thin edge around it to resize it, as in chapter 23.

The corners are rounded with the X Shape extension. Without a compositor the edge is cut pixel by pixel, so the corners look slightly stepped; the soft shadow of other desktops is not there.

!!! planned "Planned: the rest of Horizon"
    This is the first step of the Horizon look. Planned next: a **dock** at the bottom with your favourite programs, the running ones and drawers; a **search bar** for programs, settings and files; **desktop widgets** (calendar, to-dos, a photo, a clock); folder icons on the desktop; a flat look for the amadeOS applications and a Horizon icon set. Until then, the amadeOS applications keep their Motif buttons in Horizon's colours, and minimised windows become icons at the top left of the desktop, as in Classic.

!!! info "Under the hood"
    The look is stored in `~/.config/amadeos/look.conf` (`look=horizon`, `scheme=dark`, `accent=teal`); the classic palette stays in `theme.conf`. The top bar is the package **amadeos-panel-horizon**. `amadeos-session` starts the panel of the look; when the look changes, the running panel ends with exit code 75 and the session starts the other one (chapter 55). Without amadeos-panel-horizon, the Front Panel stays in both looks.
