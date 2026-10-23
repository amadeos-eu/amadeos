# 16. The First Start

After the installation, the computer starts amadeOS from its disk. A few seconds after the boot menu, the login screen appears, now with the user you created.

![The login screen of amadeOS](images/20/login-screen.jpg)

Type your password and press ++enter++. The language, keyboard and time zone you chose in the installer are already set. Chapter 20 explains every field of the login screen.

## What is different from the live system

| | Live system | Installed system |
|---|---|---|
| User | `amadeos`, password `amadeos` | The user you created |
| Your files and settings | Forgotten when you switch off | Kept on the disk |
| Starts from | The USB stick | The disk |
| *Install amadeOS* | In the Tools drawer | Removed |
| Administrator password | `amadeos` | Your own password |

The WLAN connections you used in the live system were carried over, so the network usually works at once.

## Five first steps

1. **Look around.** Chapter 21 gives a tour of the desktop.
2. **Choose your colours** in Settings (Part IV), and a larger text size if you like.
3. **Check for updates.** The update cell in the Front Panel shows when updates are waiting (chapter 52).
4. **Set up your mail** in the Mailer (chapter 44).
5. **Copy your files back** from the backup, into the folders *Documents*, *Pictures*, *Music* and so on in your home folder.

## If the computer does not start amadeOS

- **It starts Windows, or the stick again.** Remove the stick. If Windows starts, choose amadeOS in the firmware's boot menu (chapter 13) or put it first in the boot order.
- **A black screen after the boot menu.** Restart; chapter 57 shows how to start once with the simplest graphics settings (`nomodeset`).
- **The password is not accepted.** Check the keyboard layout in the login screen: with a German layout, ++y++ and ++z++ are swapped.
