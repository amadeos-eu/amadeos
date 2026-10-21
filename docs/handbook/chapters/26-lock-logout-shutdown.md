# 26. Locking, Logging Out, Shutting Down

## Locking the screen

When you leave the computer for a moment, **lock** it. Your windows stay open behind a closed screen, and only your password opens it again.

- Click the **padlock** in the middle of the Front Panel,
- or press ++super+l++ (the key with the Windows logo and ++l++),
- or choose **Lock Screen** in the Workspace Menu (right mouse button on the backdrop).

![The locked screen](images/26/lock-screen.jpg)

To unlock, type your password and press ++enter++.

The **screen saver** locks the screen by itself after a time without keyboard or mouse. How long that is, and which picture the screen saver shows, is set in the Style Manager's *Screen* settings (chapter 34).

!!! sovereignty "Your data"
    The lock grabs the keyboard and mouse for itself, so no program behind it can read what you type. If the lock program should ever crash, it starts again at once and the screen stays locked.

## The EXIT button

**EXIT**, at the right of the workspace switch, opens the window *amadeOS Session & Power Control*:

| Button | What it does |
|---|---|
| **Log Out** | Ends your session and returns to the login screen. |
| **Reboot** | Ends the session and restarts the computer; asks once more. |
| **Shut Down** | Ends the session and switches the computer off; asks once more. |
| **Exit to Shell** | For experts; for now it does the same as *Log Out*. |
| **Cancel** | Closes the window. |

*Log Out…* in the Workspace Menu does the same.

!!! warning "Save first"
    Logging out ends all your programs. Save your work before; amadeOS does not yet ask the programs to save.

## Without logging in

At the login screen, **Reboot…** and **Shut Down…** at the bottom right restart or switch off the computer (chapter 20). The power button of the computer also shuts amadeOS down properly.

!!! cde "CDE heritage"
    CDE had the same padlock and EXIT button at the same places. amadeOS adds the keyboard shortcut ++super+l++ and the choice of rebooting or shutting down directly from EXIT.
