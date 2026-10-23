# 27. Network, Sound and Printing

## The network

A **wired network** works by itself: plug in the cable, and amadeOS connects. The network cell at the right end of the Front Panel shows a cable then; its tooltip names the connection.

For a **WLAN**, click the network cell. A menu lists the networks in reach with their signal strength. Click one; for a protected network amadeOS asks for its password once and remembers it. *Show password* shows what you typed.

| In the network menu | What it does |
|---|---|
| A network | Joins it. |
| The current network | A submenu with **Disconnect** and **Forget network** (forget the password). |
| **Search again** | Looks for networks anew. |
| **Network settings…** | Opens the detailed settings in a terminal window, for fixed addresses, VPNs and hidden networks (chapter 54). |

If the cell shows a cross, there is no connection; *Not connected* in its tooltip, or *Network service is not running* if the network service itself has stopped (chapter 57).

!!! switching "Coming from Windows or macOS"
    The network cell is the network icon of the Windows taskbar or the macOS menu bar. Mobile hotspots of phones appear in the list like any other WLAN.

!!! sovereignty "Your data"
    WLAN passwords are kept on your computer only, readable by the system and its administrators. The desktop sends nothing to a server when it connects; the system only sets its clock from a public time server.

## Sound

Sound works without setting anything up: amadeOS uses PipeWire, the sound system of current Linux distributions, for speakers, headphones and USB sound cards. Programs that play sound, the Audio Station, the Video Player, the games and Firefox, use the device that is active.

Set the volume in the program that plays; most of them have a volume control.

!!! planned "Planned"
    A sound cell in the Front Panel, with the volume and the choice of the output device, will join the network and update cells. Until then, `pactl set-sink-volume @DEFAULT_SINK@ 50%` in a terminal sets the volume, and `pactl list short sinks` lists the devices.

The **beep**, the short sound the desktop makes for a mistake, is set on the *Beep* page of Settings (chapter 33).

## Printing

Most printers sold in the last ten years print without a driver (IPP Everywhere, AirPrint). Connect them by USB, or to the same network, and amadeOS finds them by itself.

Click the **Print Manager** in the Front Panel to see them. It lists the printers with their state, and for each printer its jobs:

- **Cancel**, **hold** or **release** a print job,
- **pause** and **resume** a printer,
- choose the **default printer**, the one programs offer first,
- print a **test page**.

If a printer does not appear by itself, open the Print Manager's drawer and choose **Add or Configure Printers**. That opens the administration page of the print system (CUPS) in the web browser, at <http://localhost:631>: *Administration → Add Printer*. Chapter 54 explains it in more detail.

!!! cde "CDE heritage"
    The Print Manager follows CDE's `dtprintinfo`, which had its slot at the same place on the right of the Front Panel.

??? hood "Under the hood"
    The network cell asks NetworkManager through `nmcli`; members of the group `netdev` may change connections without a password (polkit rule `/usr/share/polkit-1/rules.d/50-amadeos-network.rules`). *Network settings…* runs `nmtui`. The Print Manager `amadeos-print` speaks the printing protocol IPP to CUPS directly, over its socket `/run/cups/cups.sock`; members of the group `lpadmin` may pause printers and choose the default without a password. The first user of an installed system and the live user are in both groups.
