# 23. Working with Windows

Every program opens in a window, and every window gets the same frame from amadeOS, whatever program it belongs to.

![A window with its frame](images/23/window-frame.jpg)

## The frame

| Part | Where | What it does |
|---|---|---|
| **Window menu button** | Left end of the title bar, a small bar | Closes the window, as the program's own *Close* or *Exit* would. |
| **Title bar** | Top | Shows the window's name. Drag it to move the window. The active window's title bar has the active colour of the palette. |
| **Minimise button** | Right, the small square | Hides the window and puts an icon for it on the desktop. |
| **Maximise button** | Right, the large square | Makes the window as large as the screen above the Front Panel; a second click gives it back its size. |
| **Close button** | Right end, the cross | Closes the window. |
| **Edges and corners** | All around | Drag them to resize the window; the mouse pointer changes to show the direction. |

!!! cde "CDE heritage"
    The frame is the Motif frame of CDE's window manager `dtwm`, with its raised edges and corner pieces. In CDE, the button on the left opened the *window menu* with Restore, Move, Size, Minimize, Maximize, Lower and Close; in amadeOS it closes the window at once, and the cross on the right, which CDE did not have, does the same.

## The active window

You work in one window at a time, the **active** window: it receives what you type, and its title bar shows the active colour. Click into a window, or on its title bar, to make it active; it also comes to the front.

## Minimising and restoring

A minimised window disappears from the screen and leaves a small icon with its name at the top left of the desktop. Click the icon to bring the window back. Several minimised windows line up below each other.

The Workspace Menu (chapter 24) has *Minimize All Windows* and *Restore All Windows* under *Window Management*.

## Full screen

Programs can ask for the whole screen, for example the games with ++f11++. The frame and the Front Panel then disappear until the program leaves full screen again, with the same key.

## Closing a program

Closing the last window of a program usually ends the program. A program with unsaved work asks first, as the Text Editor does with a changed document. The close buttons ask the program to close its window; a program that does not understand that request is ended at once. A program that hangs may not answer at all; chapter 57 shows how to end it.

??? hood "Under the hood"
    The frames come from the window manager `amadeos-wm`, a Java program that talks to the X server through the X11 library. It *reparents* each window into a frame window of its own and follows the conventions ICCCM and EWMH, so programs that are not written in Java, Firefox for example, get the same frame. It is started by the session and restarted at once should it ever end. Its log is `~/.cache/amadeos/logs/wm.log`.
