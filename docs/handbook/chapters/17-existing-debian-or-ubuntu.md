# 17. On an Existing Debian or Ubuntu

You don't need the amadeOS image to use the amadeOS desktop. A computer that already runs Debian or Ubuntu can get it from the amadeOS package repository at `apt.amadeos.eu`. Your files, users and installed programs stay as they are. Only the desktop is added, and its login screen takes over from the old one.

!!! warning "Status"
    The image is what amadeOS is tested on. Installing on an existing system has been tried on Ubuntu 26.04 with Xubuntu (Xfce). Keep the old desktop until amadeOS works for you; step 5 says how to go back.

## What you need

- **Debian 13 "trixie"** or newer, or **Ubuntu 26.04** or newer (including Xubuntu, Kubuntu and the other flavours), on a 64-bit PC.
- **Java 25**: all amadeOS programs need the package `openjdk-25-jre`. Check that your system offers it:
  ```sh
  apt policy openjdk-25-jre
  ```
  If it shows no *Candidate* (German: *Installationskandidat*), your release is too old for amadeOS.
- An account that may use `sudo`.

## Step 1: Add the amadeOS repository

The package `amadeos-archive-keyring` holds the key that signs the repository and the apt entry `/etc/apt/sources.list.d/amadeos.sources`. Download it and install it:

```sh
wget https://apt.amadeos.eu/amadeos-archive-keyring.deb
sudo apt install ./amadeos-archive-keyring.deb
sudo apt update
```

Without `wget`, open the address in Firefox; it saves the file in *Downloads*, and the second line becomes `sudo apt install ~/Downloads/amadeos-archive-keyring.deb`. A note at the end that the download ran *as root and not sandboxed* is harmless. The output of `apt update` should now contain a line with `apt.amadeos.eu stable InRelease`.

## Step 2: Install the desktop

```sh
sudo apt install amadeos-desktop
```

`amadeos-desktop` is the whole desktop in one package: the login screen, the session, the window manager, the Front Panel, Settings, and the programs and games of amadeOS. Later releases bring their new programs with the normal updates (chapter 52). A few Debian packages that the image uses, such as `firefox-esr`, do not exist on Ubuntu; apt simply leaves them out.

## Step 3: Switch the login screen

Only one display manager can start at boot. Debian and Ubuntu desktops come with one of their own: LightDM (Xubuntu, many Debian installations), GDM (Ubuntu, GNOME) or SDDM (Kubuntu, KDE). Switch it off and amadeOS's on. For LightDM:

```sh
sudo systemctl disable lightdm
sudo systemctl enable amadeos-dm
sudo reboot
```

For GDM write `gdm3` instead of `lightdm`, for SDDM `sddm`. `systemctl status display-manager` tells you which one runs now. After the reboot the amadeOS login screen appears (chapter 20).

## Step 4: Remove the old desktop (optional)

Once amadeOS works, you can remove the old desktop to free space and keep its programs out of the menus. For Xubuntu:

```sh
sudo apt remove xubuntu-desktop xubuntu-core xfce4-session xfce4-panel xfwm4 xfdesktop4 lightdm
```

Read the list of packages before you confirm, and be careful with `sudo apt autoremove` afterwards: on Ubuntu it can catch more than you expect. Leaving the old desktop installed does no harm.

## Step 5: Going back

If the amadeOS login screen does not come up, press ++ctrl+alt+f3++, log in on the text console and switch back:

```sh
sudo systemctl disable amadeos-dm
sudo systemctl enable lightdm
sudo reboot
```

To remove amadeOS completely: `sudo apt remove amadeos-desktop amadeos-dm amadeos-session`, then the programs you no longer want.

## Differences from the image

- **Not yet on apt.amadeos.eu:** the NsCDE icon theme, the CDE backdrops and the offline handbooks come only with the image so far. The CDE look then uses other icons, and the handbooks are read online at <https://docs.amadeos.eu>.
- **Passwords of Electron and Chromium programs:** the Claude app, VS Code and Chromium may report that no system keyring is available, although gnome-keyring runs. Start them with `--password-store=gnome-libsecret` until an amadeOS update fixes it (issue [amadeos-system #96](https://github.com/amadeos-eu/amadeos-system/issues/96)).
- The installer, the live system and the boot menu of the image are not part of this. Your existing boot loader stays.
