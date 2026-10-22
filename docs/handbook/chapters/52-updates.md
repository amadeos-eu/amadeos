# 52. Keeping amadeOS Up to Date

Debian publishes updates for the software it ships: **security updates** that close holes as soon as they are known, and **stable updates** that fix serious bugs. amadeOS shows them to you and installs them when you say so. It never upgrades to a new Debian release by itself.

## The updates cell

When updates are waiting, the **updates cell** appears in the status slot of the Front Panel: an arrow into a tray with the number of updates. The cell is **red** when security updates are among them. Its tooltip says how many updates wait, for example *5 updates, 2 security*.

Click it for its menu:

| Entry | What it does |
|---|---|
| The first updates | Package, installed version → new version. |
| **Show updates…** | Opens the *Updates* tab of Software. |
| **Install all updates** | Installs everything that waits. |
| **Install security updates only** | Installs the security updates and leaves the rest. |
| **Check now** | Asks the Debian mirror for new updates now; needs no password. |
| **Settings…** | The setting for automatic security updates (below). |

Installing asks for your password (chapter 50). While the updates install, the cell shows the progress in per cent; when it is done, it says *The updates are installed*, and the cell disappears until the next updates arrive.

amadeOS looks for updates once a day by itself, when the computer is on and has a network. The cell needs no network to show them: it reads what that check found, every half hour and whenever something changes.

## The Updates tab

**Show updates…**, or the *Updates* tab in Software (chapter 51), lists every waiting update with the installed and the new version and its source; security updates come first and say *Security update*. Choose one to see what it is.

- Tick the updates you want and press **Install selected**; *Select all* and *Select none* help.
- **Security updates only** installs just those.
- **Software → Check for updates** asks the mirror again.

If nothing waits, the tab says *Your software is up to date* and when it last checked.

## Restarting after an update

Most updates take effect when you next start the program. An update of the Linux kernel or of a basic library takes effect only after a restart. Software then shows a bar *Restart the computer to finish the updates* with **Restart now**; the updates cell says so as well. Save your work first; you may also restart later, at a moment that suits you.

## Automatic security updates

**Software → Settings…** (or *Settings…* in the updates cell) has one switch: **Install security updates automatically**. Turned on, amadeOS installs security updates once a day in the background, without asking. Other updates still wait for you.

It is off at first, because amadeOS changes nothing without you. Turn it on for a computer that others use, or one you do not look after every week.

!!! switching "Coming from Windows or macOS"
    There are no forced restarts and no updates that install themselves during shutdown. Updates within a Debian release fix problems; they do not change how the desktop looks or works.

!!! sovereignty "Your data"
    Checking for updates downloads the package lists from the Debian mirror, like any other download. It sends no information about your computer beyond what every web request carries, the address of your connection.

## A new Debian release

About every two years Debian publishes a new release; amadeOS is based on Debian 13 *trixie*. Moving to the next release is a bigger step than an update and is not done from the desktop.

!!! planned "Planned"
    How amadeOS moves to the next Debian release will be described here, together with the amadeOS package repository (ROADMAP milestone M16).

## In the terminal

```sh
sudo apt update          # fetch the package lists
apt list --upgradable    # what would be updated
sudo apt upgrade         # install the updates
```

??? hood "Under the hood"
    The daily check is Debian's `apt-daily.timer`. The updates cell and Software read the result with apt as you; installing runs `/usr/libexec/amadeos-packages upgrade` (or `upgrade --security-only`) through `pkexec`. Security updates are those from `trixie-security`. The automatic setting writes `/etc/apt/apt.conf.d/50amadeos-unattended` and installs `unattended-upgrades` when it is first turned on. An update that needs a restart leaves `/run/reboot-required`. What was installed is logged in `/var/log/amadeos-packages.log` and `/var/log/apt/history.log`.
