# 41. File Manager

The **File Manager** shows your folders and files in **two panels** side by side: one where things are, one where they should go. Copying a file is then one key, ++f5++. Anyone who knows Midnight Commander or Total Commander will feel at home; everybody else gets the function keys printed at the bottom of the window.

Start it with the File Manager slot of the Front Panel, which opens your home folder, or with `amade-files`.

![The File Manager](images/41/file-manager.jpg)

## The window

- **The path bar** above each panel has one button per folder of the path, as in CDE: click one to go to that folder. The active panel has the coloured path bar.
- **The list** shows name, size, date and permissions. Click a column heading to sort by it.
- **The status line** below each panel shows the selected files with their size, and the free space on the disk.
- **The function-key bar** at the bottom: each button does what its key does.

*View → Two Panels* (++ctrl+f1++) switches to one panel and back.

## Moving around

| Key | What it does |
|---|---|
| ++enter++ or double-click | Opens a folder, or opens a file with its program |
| ++backspace++ | Goes to the folder above |
| ++tab++ | Switches to the other panel |
| ++ctrl+l++ | Go to a folder by typing its path (`~` for your home folder) |
| ++ctrl+h++ | Shows or hides hidden files |
| ++ctrl+u++ | Swaps the two panels |
| ++ctrl+equal++ | Shows the same folder in the other panel |
| ++ctrl+r++ | Reads the folder again |

## Selecting files

Selecting, called **marking**, is separate from the cursor bar. ++insert++ or ++space++ marks the file under the cursor and moves down; marked files are bold and red. With the mouse, ++ctrl++-click and ++shift++-click mark. ++ctrl+a++ marks all, ++ctrl+shift+a++ none, ++ctrl+i++ turns the marks around. Without marks, the commands work on the file under the cursor.

## Copying, moving, renaming

| Key | What it does |
|---|---|
| ++f5++ | Copies to the folder of the other panel (the target can be changed) |
| ++f6++ | Moves to the folder of the other panel |
| ++f2++ | Renames |
| ++f7++ | Makes a new folder |
| ++f3++ / ++f4++ | Opens the file in its program / in the Text Editor |
| ++ctrl+shift+c++ | Copies the paths of the files to the clipboard |

Copying and moving run in the background with a progress window and a *Cancel* button. If a file of the same name is already there, the File Manager shows both and asks: *Overwrite*, *Skip*, *Keep Both* (the copy is called `report (2).odt`), or the same for all files.

A copy is written under a hidden name first and gets its real name only when it is complete. A cancelled copy, a full USB stick or a pulled plug never leave a half file behind that looks like the real one.

## The trash

++f8++ or ++delete++ moves files to the **trash**. The Trash Can at the right end of the Front Panel, or *Go → Trash*, shows what is in it, with the folder each file came from and when you threw it away.

- *File → Restore from Trash* puts the marked files back where they were.
- *File → Empty Trash…* deletes everything in the trash for good, after asking.
- ++f8++ inside the trash deletes the marked files for good, after asking.

++shift+f8++ or ++shift+delete++ deletes for good straight away, after asking. Files on a USB stick go to a trash on the stick itself, so throwing them away is quick and emptying the trash frees space on the stick.

!!! switching "Coming from Windows or macOS"
    The trash is the Recycle Bin or Bin you know. It follows the freedesktop.org standard, so other Linux programs see the same trash.

!!! planned "Planned"
    Folders that refresh by themselves, quick search by typing, tabs and bookmarks, an icon view with a folder tree, drag and drop, file properties and *Open With…*, archives as folders, and folders on other computers (SFTP).

??? hood "Under the hood"
    The settings, such as hidden files and the folders of both panels when you closed the File Manager, are in `~/.config/amadeos/files/files.conf`. `amade-files /tmp /media` opens the File Manager with these folders in the left and right panel, and `amade-files trash:` opens the trash.
