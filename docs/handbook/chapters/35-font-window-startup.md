# 35. Font, Window and Startup

**Font** sets the size of the text, **Window** how the windows behave. **Startup**, the third control that CDE's Style Manager had here, is still to come.

## Font

![The Font page](images/35/settings-font.jpg)

The list on the left offers seven sizes, from *1 Smallest* to *7 Largest*; *4 Normal* is the size of a new account. Click a size and the preview on the right shows it at once: the labels, menus and buttons, the text in fields and lists, and a line of fixed-width text as in the Text Editor. Click **Apply** to keep it.

The amadeOS applications change their text at once, even while they are open, and Settings itself does too. Other desktop tools take the new size when they start next. Window titles and the Front Panel keep their size, so the desktop around your work stays the same.

!!! tip "Bigger text in other programs"
    Programs that are not part of amadeOS, such as Firefox or LibreOffice, keep their own text size. Firefox and this handbook zoom with ++ctrl+plus++ and ++ctrl+minus++.

## Window

![The Window page](images/35/settings-window.jpg)

| Setting | What it does | Default |
|---|---|---|
| **Click in window to make active** | A window gets the keyboard when you click into it. | on |
| **Point in window to make active** | A window gets the keyboard as soon as the mouse pointer moves over it, without a click. Moving the pointer onto the backdrop leaves the last window active. | off |
| **Raise window when made active** | A click into a window also brings it to the front. Without it, a click into a window behind another one gives it the keyboard but leaves it where it is. | on |
| **Show contents during move** | While you drag a window by its title bar, the whole window moves with the mouse. Without it, only an outline moves, and the window follows when you let go, as in CDE. | off |

A click on a window's title bar always brings it to the front, whatever *Raise window* says. The window manager follows a change as soon as you click **Apply**; there is no need to log out.

!!! switching "Coming from Windows or macOS"
    The defaults behave like Windows and macOS: click into a window and it comes to the front with the keyboard. *Point in window to make active* is the classic behaviour of many Unix desktops; try it with *Raise window* switched off, so that a window can be typed into while another one covers part of it.

!!! planned "Planned: Startup"
    What the desktop does when you log in and out: whether it opens the windows of your last session again, or always starts with an empty desktop. Until then, programs that should start at every login can be added to the autostart (chapter 55).

??? hood "Under the hood"
    The font size is stored as a number from 1 to 7 in `~/.config/amadeos/font.conf`; programs built on *amade-commons* watch the file and scale all the fonts of their Motif look by the same factor, from 75 % to 150 %. The window settings are in `~/.config/amadeos/window.conf` (`focus=click` or `pointer`, `raise.when.active`, `move.contents`), which the window manager watches.
