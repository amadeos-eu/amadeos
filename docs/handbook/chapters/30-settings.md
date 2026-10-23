# 30. Settings

**Settings** is where you make the desktop your own: its colours, the size of its text, the picture behind the windows, how the keyboard, the mouse and the windows behave, the sound of the beep, the screen saver and the clipboard. It grew out of CDE's Style Manager, and it can still look like it (see *The compact view* below).

## Opening it

- Open the **Tools** drawer of the Front Panel and choose **Settings** (chapter 22),
- or choose **Settings…** in the Workspace Menu (right mouse button on the backdrop, chapter 24),
- or type `amadeos-settings` in a terminal. `amadeos-settings mouse` opens it at the *Mouse* page, and so on for every control. The old name `amadeos-style` still works.

![Settings](images/30/settings.jpg)

## The sidebar

On the left, the controls are grouped by what they set. Click one, or move through them with ++arrow-up++ and ++arrow-down++, and its page appears on the right. The line above the page says where you are, for example *Appearance › Color*.

| Group | Control | What it sets | Chapter |
|---|---|---|---|
| Appearance | **Color** | The colour palette of the desktop and the icon theme | 31 |
| | **Font** | The size of the text | 35 |
| | **Backdrop** | The pattern, picture or colour behind the windows | 32 |
| Input and Sound | **Keyboard** | Key repeat and key click | 33 |
| | **Mouse** | Left or right hand, double-click speed, acceleration | 33 |
| | **Beep** | Volume, tone and length of the beep | 33 |
| Desktop | **Screen** | Screen saver and screen lock | 34 |
| | **Window** | How windows get the focus, come to the front and move | 35 |
| | **Clipboard** | The clipboard history, and copies that outlive their program | 36 |
| | **Startup** | What the session restores at login (planned) | 35 |

*Startup* is grey: amadeOS does not have it yet.

## Apply and Reset

Each page has two buttons at the bottom:

| Button | What it does |
|---|---|
| **Apply** | Saves and applies the settings of this page. |
| **Reset** | Throws away what you changed on this page since the last *Apply*, and shows the saved settings again. |

You can go to another page before you click *Apply*; your changes wait on their page until you come back. Closing the window forgets the changes that were not applied.

The line at the bottom of the window says what the last *Apply* did, for example *Palette: CDE Desert (Sand / Amber)* or *Mouse applied*.

The settings are yours alone. Another user of the same computer keeps their own colours and backdrop, and your settings come back at every login.

## Finding a setting

Type into the field **Find a setting** at the top left, or press ++ctrl+f++ first. The page shows the controls that match, and the sidebar dims the others. The search knows more than the names: *lock* finds *Screen*, *zoom* finds *Font*, *left-handed* finds *Mouse*, in the language of the desktop.

![Searching for "lock"](images/30/settings-search.jpg)

++enter++ opens the first result, ++esc++ clears the search.

## The compact view

**View → Compact (CDE controls)** turns Settings into the row of buttons of CDE's Style Manager. Each button opens its control in a window of its own:

![The compact view](images/30/settings-compact.jpg)

![A control of the compact view](images/30/settings-compact-mouse.jpg)

In that window, **OK** saves, applies and closes; **Apply** saves and applies and leaves the window open; **Cancel** closes it without changing anything. **View → Sidebar** goes back. Settings remembers the view you chose.

**File → Exit** (++ctrl+q++) closes Settings; **Help → About Settings** says what it is for.

!!! cde "CDE heritage"
    CDE's Style Manager, `dtstyle`, was a row of buttons, each opening a small window. That worked for a handful of controls; amadeOS has more to set, so the sidebar groups them and a search finds them. The compact view keeps the CDE row for those who prefer it.

??? hood "Under the hood"
    Settings writes small text files to `~/.config/amadeos/`, one per control: `theme.conf` and `icon_theme.conf` (Color), `font.conf` (Font), `wallpaper.conf` (Backdrop), `input.conf` (Keyboard, Mouse and Beep), `screen.conf` (Screen), `window.conf` (Window) and `clipboard.conf` (Clipboard); its own view is kept in `settings.conf`. The desktop and the amadeOS applications watch these files, so a change reaches them at once. Chapter 56 lists all settings files.
