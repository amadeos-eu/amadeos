# 34. Screen

**Screen** sets the **screen saver**, the moving picture that appears when you have not used the computer for a while, and the **screen lock**, which closes the screen after a longer time.

![The Screen page](images/34/settings-screen.jpg)

## The screen saver

| Setting | What it does | Default |
|---|---|---|
| **Screen saver** | Switches the screen saver on or off. | on |
| **Start after … minutes** | How long without keyboard or mouse before it starts. | 10 minutes |
| **The list** | Which screen saver it shows. | Qix |

The screen savers:

| Screen saver | What it shows |
|---|---|
| **Random** | A different one of the others each time. |
| **Blank** | A black screen. |
| **Qix** | Coloured lines that bounce across the screen, the classic of the X11 screen savers. |
| **Swarm** | A swarm of bees chasing a wasp, after the old X11 screen saver. |
| **Starfield** | A flight through the stars. |
| **Floating Logo** | The amadeOS logo and the time, drifting slowly across the screen. |

The **preview** to the right of the list runs the chosen screen saver in small. **Test** shows it on the whole screen; any key or mouse click ends it.

The screen saver ends at the next key press or mouse movement and does not ask for a password. That is the lock's job.

## The screen lock

| Setting | What it does | Default |
|---|---|---|
| **Screen lock** | Locks the screen by itself after a time without input. | on |
| **Lock after … minutes without input** | How long before it locks. | 15 minutes |

The lock takes over from a running screen saver. Only your login password opens the screen again (chapter 26). To lock at once, use the padlock in the Front Panel or ++super+l++.

!!! sovereignty "Your data"
    Leave the lock on, especially on a laptop. A screen saver alone only hides the screen; anyone who touches the mouse sees your open windows.

??? hood "Under the hood"
    The settings are stored in `~/.config/amadeos/screen.conf`. The screen saver program of the session, started by `/etc/amadeos/autostart.d/50-amadeos-screen`, asks the X server how long there has been no input, starts the screen saver and the lock at the set times, and reads the file again whenever it changes; there is no need to log in again.
