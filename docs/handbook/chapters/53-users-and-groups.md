# 53. Users and Groups

Every person who uses the computer should have an **account** of their own: their own home folder, their own settings, their own password. Accounts keep the family's or the club's documents apart, and one user's mistake does not reach the others' files.

## Users

The installer creates the first user (chapter 14). Further users are added by an administrator. The greeter lists every user at login (chapter 20).

!!! planned "Planned"
    A *Users* program in the Tools drawer to add, change and remove accounts with a few clicks. Until then, accounts are managed with a few commands in the **Root Console** (chapter 50).

### Adding a user

```sh
sudo adduser maria
```

`adduser` asks for the new password twice, then for the full name and a few optional details (*Room Number*, *Work Phone*…); press ++enter++ to leave those empty. Maria can log in at once.

To give the new user the same rights to use the network, sound, printers and scanners as the first user, add her to these groups:

```sh
sudo usermod -aG audio,video,plugdev,netdev,scanner,lpadmin maria
```

### Making a user an administrator

```sh
sudo usermod -aG sudo maria
```

Maria can then install software and do everything else an administrator does, with her own password. The change counts from her next login.

!!! warning
    An administrator can read every file on the computer, including those of other users. Make only people administrators whom you would also give the key to the house.

### Changing a password

Each user changes their own password in a terminal:

```sh
passwd
```

An administrator sets a new password for someone who forgot theirs:

```sh
sudo passwd maria
```

The login keyring of that user, where programs such as the Mailer keep passwords, was locked with the old password. After an administrator has set a new one, the old saved passwords cannot be opened any more and have to be typed again once.

### Removing a user

```sh
sudo deluser maria                 # keeps /home/maria
sudo deluser --remove-home maria   # removes her files too
```

## Groups

A **group** gives its members a right. The ones that matter on amadeOS:

| Group | Its members may |
|---|---|
| `sudo` | Administer the computer (chapter 50). |
| `netdev` | Change network connections and join WLANs without a password. |
| `lpadmin` | Pause printers and choose the default printer. |
| `scanner` | Use scanners. |
| `audio`, `video` | Use sound and graphics devices directly. |
| `plugdev` | Use removable devices such as USB sticks and phones. |
| `systemd-journal` | Read the system log (chapter 57). |

`groups` shows your own groups; `groups maria` those of another user.

!!! switching "Coming from Windows or macOS"
    The *Standard* and *Administrator* account types of Windows and macOS are, on amadeOS, a user outside or inside the group `sudo`.

!!! sovereignty "Your data"
    Accounts are local: they exist only on this computer, and no online account is linked to them. The home folder of each user is readable only by that user (and the administrators).

??? hood "Under the hood"
    Users are in `/etc/passwd`, their password hashes in `/etc/shadow`, groups in `/etc/group`. `adduser` copies `/etc/skel` into the new home folder. The installer puts the first user into the groups `audio cdrom dip floppy video plugdev netdev powerdev scanner bluetooth lpadmin systemd-journal sudo`; the live user has the same.
