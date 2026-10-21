# 25. Your Language

amadeOS speaks five languages: **English**, **Deutsch**, **Français**, **Español** and **Italiano**. The desktop, the Front Panel, the Style Manager and the amadeOS applications all follow the language you choose.

## Where to choose it

**At the login screen.** The *Language* field (chapter 20) sets the language for the whole session. Your last choice is preselected next time.

**In the Front Panel.** The language button under the padlock, in the middle of the panel, shows the current language as a code such as *EN* or *DE*. Click it and choose another language from the menu. Programs you start from then on use the new language; the Front Panel itself and the terminals follow at the next login.

**In a single application.** Many amadeOS applications have a language setting of their own in their *Settings* or *Options*. It overrides the desktop language for that application only.

!!! tip "Already open windows"
    A program that is already open keeps its language. Close it and start it again to see it in the new language.

## The keyboard is separate

The language does not change the keyboard. A French desktop can be typed on a German keyboard and the other way round. The keyboard layout is chosen at the login screen and, for good, in the installer; the Style Manager's *Keyboard* settings (chapter 33) set its repeat rate and click.

## Region

The language can come with a region, such as Austrian German (`de_AT`) or Swiss French (`fr_CH`). The region decides details such as the format of dates and numbers. The menus offer the five languages; a region is set by writing it into the settings file below, and a language chosen in the menus keeps a region that is already there.

??? hood "Under the hood"
    Both the login screen and the language button write the choice to `~/.config/amadeos/locale.conf`, one line such as `de` or `de_AT`. The applications built on the library *amade-commons* read this file when they start; the session sets the environment variable `LANG` from it at login, which the Front Panel, terminals and other programs follow. The texts of the desktop are in `.properties` files, one per language, in the source code of each program, so a new language is a matter of translating those files.

!!! planned "Planned"
    More languages are welcome as contributions. Firefox is installed with the five languages already.
