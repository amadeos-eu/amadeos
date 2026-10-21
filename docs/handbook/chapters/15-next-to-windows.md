# 15. Next to Windows

amadeOS can live on the same disk as Windows. At every start, a menu lets you choose which of the two to start. This chapter explains how to prepare the computer, and what to watch out for.

!!! warning "Status"
    Installing next to Windows works in virtual machines but has not been tried on many real computers yet (milestone M14). Make a backup of Windows and your files before you start.

## What happens

The disk of a Windows computer is divided into *partitions*: an **EFI System Partition** with the boot loaders, the Windows partition `C:` and usually a small recovery partition. amadeOS needs a partition of its own, of at least 8 GB.

The installer takes that partition and formats it; the other partitions stay as they are. On UEFI computers it shares the EFI System Partition with Windows: it adds its own boot loader in the folder `EFI/amadeos` and leaves Windows' files untouched. The boot menu of the installed amadeOS then offers **amadeOS** and **Windows Boot Manager**.

## Step 1: Check BitLocker

Windows often encrypts its disk with **BitLocker**, also called *Device encryption* on Windows 11 Home. Windows ties the key to the state of the firmware. When you switch Secure Boot off for the live stick, or change the boot order, Windows may ask once for its **48-digit recovery key** at the next start. After it has been typed in, Windows stops asking.

So before you change anything:

1. In Windows, open a command prompt as administrator and type `manage-bde -status C:`. *Protection On* means BitLocker is active.
2. If it is, find the recovery key and write it down or print it:
    - with a Microsoft account, at <https://account.microsoft.com/devices/recoverykey> (laptops sold with Windows 11 usually saved it there),
    - in Windows, under *Settings → Privacy & security → Device encryption*, or *Manage BitLocker* in the Control Panel (*Back up your recovery key*),
    - for a work or school computer, from the organisation's administrator.

!!! danger "Without the recovery key"
    If Windows asks for the key and you do not have it, the files on `C:` are lost for good. Do not go on until you have the key or know that BitLocker is off.

## Step 2: Switch off Fast Startup

Windows' *Fast Startup* does not really shut Windows down; it leaves the disk in a half-hibernated state. amadeOS cannot then safely read the Windows partition. Switch it off in Windows: *Control Panel → Power Options → Choose what the power buttons do → Change settings that are currently unavailable*, untick **Turn on fast startup**.

## Step 3: Make room for amadeOS

amadeOS needs its own partition. The installer cannot shrink Windows yet, so make the room in Windows:

1. Right-click the Start button and choose **Disk Management**.
2. Right-click the partition `C:` and choose **Shrink Volume…**. Enter how much space to free, at least 8000 MB, better 20000 MB or more.
3. Right-click the new *Unallocated* space, choose **New Simple Volume…** and go through the assistant: the whole size, **Do not assign a drive letter or drive path**, any file system and a volume label such as `amadeOS`. The installer formats this partition anew, so the file system chosen here does not matter; the label helps you recognise it.

amadeOS has no partitioning program of its own yet, which is why the partition is made in Windows. If there is an older Linux on the computer, you can also give amadeOS its partition.

## Step 4: Install

Start the live system (chapter 13; with Secure Boot off) and the installer (chapter 14). On the **Target Disk** page choose **Install into an existing partition** and the partition you prepared. The list shows each partition with its size and label; check it twice: the installer formats the partition you choose, and if that were the Windows partition, Windows would be gone.

On UEFI computers, the page also asks which **EFI System Partition** to use; *Automatic (the first one on the disk)* is right on almost every computer.

## Step 5: The boot menu

After the installation, the computer starts the boot menu of amadeOS (GRUB). It offers amadeOS first and *Windows Boot Manager* below it. Use the arrow keys and ++enter++; *Advanced options for amadeOS* holds a recovery mode for emergencies (chapter 57); without a key, amadeOS starts after a few seconds.

You can now switch **Secure Boot** on again in the firmware settings: the installed amadeOS starts through Debian's signed boot loader.

If the computer starts Windows directly, its firmware still puts Windows first. Choose *amadeOS* in the firmware's boot menu (chapter 13), or move it to the top of the boot order in the firmware settings.

## The clock

Windows keeps the computer's hardware clock in local time, Linux in UTC. After you start one system and then the other, one of them may show a time that is off by one or two hours until it has set the clock from the network again.

!!! planned "Planned"
    The installer does not settle the clock between Windows and amadeOS yet, and it cannot shrink the Windows partition itself (milestone M14).
