# 38. Network, Passwords, Updates and Language

The *System* group of Settings has the settings that reach below the desktop: the proxy through which programs reach the internet, the keyring with your passwords, the updates of the system, and the language and time zone.

## Network

![The Network page](images/38/settings-network.jpg)

In an office, a school or a library the way to the internet often leads through a **proxy**. The Network page sets it once for all of amadeOS: the amade applications (Audio Station, TV, the Mailer, the Image Viewer's maps, Software), the programs they start (the video player, `yt-dlp`, the backup), and everything you start from the Front Panel, Firefox and the terminals included.

| Choice | What it means |
|---|---|
| **Use the proxy variables of the session** | The default. Programs use what the variables `http_proxy` and `https_proxy` say, if an administrator set them; the line below shows what they say now. Without them, programs connect directly. |
| **No proxy, always connect directly** | Programs ignore any proxy. |
| **Use this proxy** | The proxy you enter: its name or address and its port, for example `proxy.example.org` and `3128`. Untick **Use the same proxy for HTTPS** if secure connections go through another one. |

**No proxy for** lists the names reached directly, separated by commas: `localhost, .intranet.example.org` reaches every computer whose name ends in `.intranet.example.org` without the proxy. Addresses of your own network, such as a printer at `192.168.1.20`, are always reached directly.

If the proxy asks you to sign in, enter the **user name** and **password**. The password is kept in your login keyring (below), not in a file.

**Test** tries the settings before you apply them: *Works* means the proxy let amadeOS through; otherwise the line says whether the proxy wants a password, refused it, or could not be reached.

**Also for installing software and updates** lets Software and the automatic updates (chapter 52) download through the proxy as well. Clicking **Apply** after changing it, or after changing the proxy while it is ticked, asks for the administrator's password.

Programs follow a change at once, even those already open. Terminals keep the old setting until you log in again.

!!! planned "Planned: automatic configuration"
    Some networks hand out their proxy through an automatic configuration file (PAC or WPAD). amadeOS does not read it yet; enter the proxy by hand.

## Passwords

![The Passwords page](images/38/settings-passwords.jpg)

Programs such as the Mailer keep their passwords in your **login keyring** (chapter 58). The page shows whether the keyring is **unlocked** or **locked**, and how many passwords and keys it holds.

| Button | What it does |
|---|---|
| **Lock Now** | Locks the keyring. Programs can no longer read their passwords; the next one that needs a password asks you again. |
| **Unlock…** | Asks for the keyring's password and unlocks it. |
| **Change Password…** | Asks for the current password and a new one, twice. |

The login screen unlocks the keyring with your login password, as long as both passwords are the same. When you change your login password, change the keyring's to the same one here; otherwise the keyring stays locked after the next login, and you unlock it on this page.

If the page says that no keyring is running, the session was started without GNOME Keyring; programs then ask for their passwords each time.

## Updates

![The Updates page](images/38/settings-updates.jpg)

**Install security updates automatically** is the same switch as *Software → Settings…* (chapter 52): turned on, amadeOS installs security updates once a day in the background, and other updates wait for you. Clicking **Apply** after changing it asks for the administrator's password.

Below, the page shows when the package lists were last checked and how many updates are waiting, and how many of them are security updates. **Open Software…** opens Software at its *Updates* tab, where you install them.

## Language

![The Language page](images/38/settings-language.jpg)

**Language of the desktop** is the language of the menus and windows: English, Deutsch, Français, Español or Italiano. It is the same choice as the language button of the Front Panel and the login screen (chapter 25). Programs started after **Apply** speak the new language; the Front Panel, the window manager and the terminals follow at the next login.

**Time zone** sets the time zone of the computer's clock. The time zone holds for all users of the computer, so **Apply** asks for the administrator's password.

!!! planned "Planned: formats of their own"
    Dates, times and numbers follow the language of the desktop. Choosing their format separately, for example English texts with German dates, is planned.

??? hood "Under the hood"
    The Network page writes `~/.config/amadeos/proxy.conf`; the password is in the keyring under `service amadeos account proxy`. The amade applications follow the file at once. At login the session turns it into the variables `http_proxy`, `https_proxy` and `no_proxy` (`/usr/libexec/amadeos-proxy-env`), and programs started from the desktop get them as they are at that moment. For apt, `/usr/libexec/amadeos-packages proxy` writes `/etc/apt/apt.conf.d/80amadeos-proxy`, which only root can read. The Passwords page talks to the keyring over the freedesktop.org Secret Service on the session bus; locking and unlocking use GNOME Keyring's own interface for its master password. The Updates page reads the same state as the updates cell and writes the automatic setting through `/usr/libexec/amadeos-packages` and `pkexec`. The language is written to `~/.config/amadeos/locale.conf`; the time zone is set with `timedatectl set-timezone`, which polkit allows to administrators.
