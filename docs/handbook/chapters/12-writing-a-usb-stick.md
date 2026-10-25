# 12. Writing a USB Stick

The image is a *hybrid* image: it is written onto the stick as it is, byte for byte, and the stick then starts on computers with BIOS and with UEFI. Copying the file onto the stick like a document does **not** work.

!!! warning "This erases the stick"
    Writing the image replaces everything on the stick. Take care to choose the stick, not another disk of your computer.

## On Linux

The safest way is the program *Disks* (GNOME Disks), which most Linux systems have: choose the stick on the left, open the menu at the top right and choose *Restore Disk Image…*, then the image.

In a terminal, `dd` does the same:

```bash
lsblk -d -o NAME,SIZE,MODEL,TRAN      # find the stick: TRAN is usb, e.g. sdb
sudo umount /dev/sdX?*                # unmount its partitions, if they were mounted
sudo dd if=amadeos-1.0.0-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync oflag=direct
```

Replace `sdX` with the name of the stick, the whole device (`/dev/sdb`) and not a partition (`/dev/sdb1`). Check the name twice: `dd` overwrites whatever device it is given, without asking. When `dd` returns, the stick is ready and can be removed.

## On Windows

Use [Rufus](https://rufus.ie/), a small free program:

1. Insert the stick and start Rufus. Choose the stick under *Device*.
2. Click *SELECT* and choose `amadeos-1.0.0-amd64.iso`.
3. Click *START*. Rufus asks how to write the image: choose **Write in DD Image mode**.
4. Confirm that the stick will be erased, and wait until Rufus shows *READY*.

The ISO mode of Rufus copies files instead of the image and makes a stick that may not start amadeOS; the DD mode is the right one.

## On macOS

In the Terminal:

```bash
diskutil list                         # find the stick, e.g. /dev/disk4
diskutil unmountDisk /dev/diskN
sudo dd if=amadeos-1.0.0-amd64.iso of=/dev/rdiskN bs=4m
```

Replace `N` with the number of the stick. The `r` in `/dev/rdiskN` makes writing much faster. When `dd` is done, macOS may say that it cannot read the disk; choose *Eject*.

## Did it work?

Afterwards the stick contains a small partition named `amadeOS` that Windows and macOS may not be able to read. That is normal. The real test is starting the computer from it, which is the next chapter.
