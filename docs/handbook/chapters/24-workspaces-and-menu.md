# 24. Workspaces and the Workspace Menu

## Four workspaces

amadeOS has four **workspaces**, four desktops side by side, called *One*, *Two*, *Three* and *Four*. Each holds its own windows. You might keep your mail and calendar in *One*, a letter you are writing in *Two* and a game in *Four*, and switch between them without moving a single window.

The four buttons in the middle of the Front Panel switch between the workspaces. Each has its own colour from the palette, and the button of the current workspace is pressed in. A new window opens in the workspace you are in.

![Workspace Two, still empty, with the windows of workspace One out of sight](images/24/workspace-two.jpg)

The Front Panel and the backdrop are the same on all workspaces; only the windows change.

!!! cde "CDE heritage"
    CDE gave every workspace its own colour from the palette, so you always see where you are; amadeOS keeps that. In CDE the workspace buttons could be renamed and their number changed; amadeOS has four fixed ones for now.

!!! planned "Planned"
    There is no menu entry or key yet to move a window to another workspace or to show it on all of them. A window stays in the workspace where it was opened, unless the program itself asks for another one.

## The Workspace Menu

Click the **right mouse button on the backdrop** to open the Workspace Menu.

![The Workspace Menu](images/24/workspace-menu.jpg)

| Entry | What it does |
|---|---|
| **Programs** | All installed programs, sorted by kind, the same ones as in the drawers. |
| **New Window** | A *Terminal Emulator*, the *Text Editor* or a *File Manager* window with your home folder. |
| **Workspaces** | Switches to *Workspace 1: One* to *Workspace 4: Four*; the current one has a tick. |
| **Window Management** | *Shuffle Up* and *Shuffle Down* bring the bottom window to the front or send the front window to the back, one at a time; *Minimize All Windows* clears the workspace, *Restore All Windows* brings them back. |
| **Style Manager…** | Opens the Style Manager (Part IV). |
| **Refresh Desktop** | Draws the desktop and all frames anew, if something on the screen looks wrong. |
| **Lock Screen** | Locks the screen (chapter 26). |
| **Log Out…** | Ends the session (chapter 26). |

Click an entry, or click elsewhere to close the menu without choosing.

!!! cde "CDE heritage"
    CDE called it the *Workspace Menu* too and opened it the same way. Its entries could be edited in a file (`dtwmrc`); amadeOS builds its menu from the installed programs.
