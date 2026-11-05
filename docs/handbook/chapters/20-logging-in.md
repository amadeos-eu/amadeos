# 20. Logging In

When amadeOS starts, it shows the login screen. Here you say who you are, and you choose the language, keyboard and time zone for the session.

The login screen has the look of the session it will start (chapter 29). In the **Horizon** look it shows a rounded box over Horizon's picture, with a round picture of the user's first letter; at the top a slim bar with the computer name on the left and the date and time on the right.

![The login screen in the Horizon look](images/20/login-screen-horizon.jpg)

In the **classic** look it is a framed Motif box on the slate blue of a UNIX workstation. At the top left the screen names the computer (*amadeOS UNIX Workstation* and the computer name in brackets), at the top right the date and time.

![The login screen in the classic look](images/20/login-screen.jpg)

In both looks the login box is in the middle and the power buttons are at the bottom right. Which look you see: the one of the *Session* you choose. For *amadeOS Desktop* it is the look the user had last time; a user who never chose one sees Horizon, as the desktop then starts with Horizon. Choose another session or type another user name, and the screen changes its look at once.

## The fields

| Field | What it does |
|---|---|
| **User Name** | Proposed with the user who logged in last. Type another name to log in as someone else. |
| **Password** | Your password. The cursor waits here, so you can type at once. |
| **Session** | *amadeOS Desktop*, the normal desktop in the look of your last session; *amadeOS Classic (CDE)* or *amadeOS Horizon*, the desktop in that look, which then stays for later logins (chapter 29); or *Failsafe Terminal*, a single terminal window for repairs when the desktop does not start (chapter 57). |
| **Language** | The language of the desktop and the applications: English, Deutsch, Français, Español or Italiano. Your last choice is preselected. |
| **Keyboard** | The keyboard layout, preselected with the one of the computer (chosen in the installer; German on the live system). Another layout switches at once, before you type the password. |
| **Time Zone** | The time zone of the computer's clock. The current one is preselected; a change holds for the whole computer, not only for you. |

Press ++enter++ or click **Log In**. **Clear** empties the fields. If the password is wrong, the box says so under the fields, and you can try again.

!!! tip "The password is not accepted?"
    Check the keyboard first. On a German keyboard ++y++ and ++z++ are swapped, and some symbols are elsewhere. Typing the password into the user name field shows what the keyboard really types; delete it again afterwards.

## Switching off without logging in

**Reboot…** (in Horizon **Restart…**) restarts the computer, **Shut Down…** switches it off. Both ask once more before they act.

!!! cde "CDE heritage"
    The login screen follows CDE's `dtlogin`: a framed login box in the middle of the screen, the workstation name above it and the options for language and session. CDE hid language and session in an *Options* menu; amadeOS shows them as fields, because most people never found that menu.

??? hood "Under the hood"
    The login screen is the *greeter* of the display manager `amadeos-dm`. The systemd unit `amadeos-dm.service` starts the X server on virtual terminal 7 and the greeter on it. The password is checked through PAM (`/etc/pam.d/amadeos-dm`) by a separate process running as root; after a successful login it opens a session for the user with systemd-logind and starts `amadeos-session` as that user. The last user name is kept in `/var/lib/amadeos-dm/last-user`, the chosen language in `~/.config/amadeos/locale.conf`. The greeter takes its look from the user's `~/.config/amadeos/look.conf` (look, scheme and accent) and `theme.conf` (the classic palette); Horizon's picture is `/usr/share/backgrounds/amadeos/horizon-dark.png` or `horizon-light.png`.

    To see the greeter without logging out, `java -jar /opt/amadeos-dm/amadeos-dm.jar greeter` shows it in a window; it logs nobody in.
