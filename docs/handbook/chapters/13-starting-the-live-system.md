# 13. Starting the Live System

The *live system* is a complete amadeOS that runs from the USB stick. It does not touch the disk of your computer, so you can try everything safely: the desktop, the applications, the network, the printer. When you switch the computer off, the live system forgets what you did and the computer starts as before.

## Starting from the stick

1. Switch the computer off and insert the stick.
2. Switch it on and, at once, press the key for the **boot menu** several times. It is often ++f12++, ++f11++, ++f9++, ++f8++ or ++esc++, depending on the manufacturer; the first screen of the computer usually names it for a moment.
3. In the boot menu, choose the USB stick. On UEFI computers it may appear twice, once with *UEFI* in front: choose that one.

If the computer starts its usual system instead, it did not see the stick in time. Try again and press the key earlier, or look in the firmware settings (often ++f2++ or ++del++) for the boot order.

## Secure Boot

Most computers sold with Windows have *Secure Boot* switched on: the firmware starts only boot loaders signed by Microsoft. The boot loader of the amadeOS live stick is not signed yet, so with Secure Boot on, the computer refuses the stick, often with a message such as *Secure Boot violation* or simply by starting Windows.

In that case, open the firmware settings (often ++f2++, ++del++ or ++f10++ right after switching on), find *Secure Boot* (usually under *Security* or *Boot*), switch it **off**, save and restart. An installed amadeOS starts with Secure Boot on, so you can switch it back on after the installation.

!!! warning "BitLocker"
    If Windows on this computer uses BitLocker disk encryption, changing Secure Boot can make Windows ask for its 48-digit recovery key at the next start. Read the BitLocker section of chapter 15 *before* you change the setting.

!!! planned "Planned"
    A live stick that starts with Secure Boot on, through Debian's signed boot loader, is planned for the first release (milestone M12).

## The boot menu of amadeOS

The stick shows its own menu for a few seconds:

| Entry | What it does |
|---|---|
| **amadeOS Live (amd64)** | Starts the live system. This is the one you want; it starts by itself after a few seconds. |
| **amadeOS Live (amd64 failsafe)** | Starts with careful settings for difficult hardware: try it if the normal entry ends with a black screen. |

On UEFI computers the entries say *amd64 UEFI*. After the entry, Linux starts; after a short while the login screen appears.

## Logging in to the live system

The live system has one user:

| User name | Password |
|---|---|
| `amadeos` | `amadeos` |

The login screen proposes the user already, so you type the password and press ++enter++. In the same screen you can choose your language, your keyboard and your time zone (chapter 20 explains them). The live system starts with a German keyboard; if yours is different, choose your layout under *Keyboard*, for example *English (US) (us)*, before you type the password.

!!! sovereignty "Your data"
    Nothing you do in the live system is kept: files, settings and WLAN passwords are gone when you switch off. Save anything you want to keep onto another USB stick, or install amadeOS (next chapter), which takes the WLAN connections of the live session along.

## Trying amadeOS in a virtual machine

You can also start the image in a *virtual machine*, a computer simulated by a program, without a USB stick and without restarting. With [QEMU](https://www.qemu.org/) on Linux, the amadeos repository has a ready script:

```bash
./run-qemu.sh                    # start the live system (2 GB of memory)
./run-qemu.sh --install-disk     # ... with an empty 20 GB virtual disk to install onto
./run-qemu.sh --boot-disk        # start the amadeOS installed on that disk
```

`--uefi` starts the machine with UEFI firmware instead of BIOS. VirtualBox and other virtual machines work too: create a 64-bit Linux machine with 2 GB of memory, choose the image as its optical disk and start it.
