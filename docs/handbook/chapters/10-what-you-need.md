# 10. What You Need

amadeOS runs on ordinary PCs and laptops. You do not need new hardware; a computer that ran Windows 10 well is usually more than enough.

## The computer

| | Minimum | Recommended |
|---|---|---|
| Processor | 64-bit Intel or AMD (x86-64, "amd64") | Two cores or more |
| Memory | 2 GB | 4 GB or more, if you browse the web a lot |
| Disk | 8 GB for an installation | 20 GB or more, for your own files |
| Screen | 1024 × 768 | 1280 × 800 or more |
| Start-up | BIOS or UEFI | UEFI |

Computers with ARM processors (most tablets, Apple computers with M chips, some new Windows laptops with Snapdragon) are not supported. On a Mac with an Intel processor, amadeOS starts like on any PC, but this has hardly been tried.

Graphics cards from Intel, AMD and NVIDIA work with the free drivers of Linux. amadeOS needs no 3D acceleration, so even an old graphics chip is enough.

!!! switching "Coming from Windows or macOS"
    *BIOS* and *UEFI* are the two kinds of firmware a PC starts with, the program that runs before any operating system. Computers from about 2012 onwards use UEFI, older ones BIOS. amadeOS starts with both, so you usually do not need to know which one yours has. Chapter 13 explains the one setting that matters, *Secure Boot*.

## A USB stick

To try and install amadeOS you write it onto a USB stick of **at least 4 GB**. Everything on the stick is erased, so use one whose contents you do not need, or copy them away first. After the installation you can use the stick for other things again.

## A network, if you have one

amadeOS installs without a network: everything it needs is on the stick. A network (cable or WLAN) is useful for the web browser, mail and updates afterwards.

## A backup

Installing amadeOS onto a whole disk **erases that disk**. Installing it next to Windows (chapter 15) keeps Windows, but changes the partitions of the disk. In both cases, copy your important files to another disk or stick first.

!!! sovereignty "Your data"
    A backup is the first step to independence: files that exist only on one computer, or only in one company's cloud, are not really in your hands.

## Trying before installing

You do not need to decide anything yet. The USB stick starts a complete amadeOS *live system*, which runs from the stick and changes nothing on the computer. Chapter 13 shows how to start it, and you can work with it for as long as you like before you install.
