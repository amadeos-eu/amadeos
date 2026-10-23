# 48. Calculator, Web Browser and Handbooks

## Calculator

The **Calculator** is a desk calculator, a scientific calculator and a programmer's calculator in one window. It computes exactly with decimal numbers, so 0.1 + 0.2 is 0.3 and not 0.30000000000000004, and it follows the rules of arithmetic: 2 + 3 × 4 is 14.

Start it from the Text & Office drawer, or with `amade-calculator`.

![The Calculator with the paper tape](images/48/calculator.jpg)

### Three modes

The **View** menu switches between the modes; the Calculator starts in the one you used last.

- **Basic** (++ctrl+1++): the four basic operations, percent, ± and the memory.
- **Scientific** (++ctrl+2++): brackets, powers and roots, logarithms, trigonometry, π and e.
- **Programmer** (++ctrl+3++): whole numbers in hexadecimal, decimal, octal and binary, and operations on bits.

The number you are working with stays when you change the mode. Going to Programmer drops the part after the decimal point.

### Calculating

Type a calculation as you would write it, with the mouse or the keyboard, and finish it with **=** or ++enter++. The small line at the top of the display shows the whole calculation, the large number the result or the number you are typing.

- **Functions** such as √x, x² or sin work at once on the number in the display, as on a pocket calculator: type 16 and press √x, and the display shows 4 and the line above `√(16)`.
- **Percent** works as on a desk calculator: 200 + 10 % is 220 (200 plus 10 % of it), 100 × 19 % is 19.
- Pressing **=** again repeats the last operation: 2 + 3 = = = counts 5, 8, 11.
- **C** (++esc++, **AC** in Programmer) clears everything, **⌫** (++backspace++) the last digit. A wrong calculation, such as a division by zero, shows a message in the display until the next key.
- **MC, MR, M+, M−** use the memory: M+ adds the number in the display to it, MR brings it back. An **M** in the display shows that something is in the memory.
- *Edit → Copy* (++ctrl+c++) copies the result for other programs, *Edit → Paste* (++ctrl+v++) takes a number from them. Numbers such as `1.234,50`, `1,234.50` or `1 234,50` are understood.

### The keyboard

All the main keys have a key on the keyboard: the digits, `.` or `,` for the decimal point, `+ - * /`, `^` for powers, `%`, `(` and `)`, `!` for the factorial, ++enter++ for =, ++delete++ to clear the number you are typing. The key on the screen lights up when you type it.

### The paper tape

*View → Paper Tape* (++ctrl+t++) shows a strip of paper next to the keys, as on an adding machine: every finished calculation with its result. **Copy** puts the whole tape on the clipboard as text, for a mail or a document; **Clear** starts a new one. The tape is kept while the Calculator is open.

### Scientific

![The Scientific mode](images/48/calculator-scientific.jpg)

Next to the basic keys are brackets, x², x³, xʸ, √x and the y-th root, 1/x, the factorial n!, the trigonometric functions and their hyperbolic forms, logarithms to the base e, 10 and 2, the powers eˣ, 10ˣ and 2ˣ, the absolute value |x|, π and e. **2nd** turns sin, cos and tan into their inverses for one key press. **DEG** switches between degrees and radians; sin 30 in degrees is exactly 0.5. **EE** enters a power of ten (1.5 EE 3 is 1500), **mod** gives the remainder of a division, **Rnd** a random number, **Ans** the last result.

Very large and very small numbers appear as `1.5e+20`, which means 1.5 × 10²⁰. The Calculator keeps 34 digits and shows 16.

### Programmer

![The Programmer mode](images/48/calculator-programmer.jpg)

The Programmer mode works with whole numbers as a computer does. The number is shown in all four number bases at once, **HEX**, **DEC**, **OCT** and **BIN**; click one to type numbers in that base (the keys A to F are for hexadecimal). The **word size**, from 8 to 64 bits, and **Signed** decide how large a number can be: in 8 bits with a sign, 127 + 1 gives −128, as in a computer's register. Division drops the remainder.

The keys **AND, OR, XOR, NOT, NAND, NOR** combine the bits of two numbers, **<<** and **>>** shift them, **RoL** and **RoR** rotate them by one place, **mod** gives the remainder. The field of bits shows each bit of the number, numbered from 0 on the right; click a bit to switch it between 0 and 1.

!!! tip "Grouping"
    The Calculator groups digits as your language does, `1,234,567.5` in English and `1.234.567,5` in German. *View → Digit Grouping* switches that off.

!!! planned "Planned"
    A fourth mode for converting units such as length, weight and temperature, and later currencies.

??? hood "Under the hood"
    The Calculator computes with Java's `BigDecimal` to 34 digits, the precision of the decimal numbers of the IEEE 754 standard. Roots of non-square numbers, logarithms and the trigonometric functions are rounded to 15 digits. Its settings are in `~/.config/amadeos/calculator/calculator.properties`.

## Firefox

The web browser of amadeOS is **Firefox ESR**, the long-term version of Firefox that receives security updates for a long time without changing its face every few weeks. It is installed in the five languages of amadeOS.

Start it from the Mail & Internet drawer of the Front Panel, or by clicking a web link in any program. The Mailer and the Documentation Viewer hand web links to Firefox; the Mailer shows you first where a link really goes.

amadeOS sets Firefox up for privacy from the first start:

- **No telemetry** and no studies: Firefox sends no usage data to Mozilla.
- **No sponsored content**: no sponsored tiles and suggestions on the start page or in the address bar, no Pocket, no recommendations.
- **Ecosia** is the search engine, a search engine from Berlin that plants trees with its income. Any other can be chosen in the settings.
- **uBlock Origin** is installed, which blocks advertising and trackers. It can be switched off for single sites with its icon.

These are defaults. Everything can be changed in Firefox's settings, and the changes are yours.

!!! sovereignty "Your data"
    Firefox is developed by Mozilla, which belongs to a non-profit foundation, under a free licence, and its engine, Gecko, is one of the last that does not come from one of the large technology companies.

??? hood "Under the hood"
    The defaults are a Firefox *policy* file, `/usr/share/firefox-esr/distribution/policies.json`, which applies to every user of the computer.

## The Documentation Viewer

The **Documentation Viewer** shows the documentation that comes with the installed programs, under `/usr/share/doc`, and other local HTML and text files. It starts in a second and needs no network: it loads nothing from the internet, and web links go to Firefox.

Open it from the Help drawer, or with `amade-web file.html`.

![The Documentation Viewer](images/48/documentation-viewer.jpg)

| Key | What it does |
|---|---|
| ++ctrl+l++ | Type an address or a path |
| ++ctrl+o++ | Open a local file |
| ++alt+arrow-left++ / ++alt+arrow-right++ | Back / forward |
| ++alt+home++ | The start page, `/usr/share/doc` |
| ++f5++ | Reload |
| ++ctrl+plus++ / ++ctrl+minus++ / ++ctrl+0++ | Larger / smaller text / normal size |

It shows HTML pages, folders (with their `index.html`, or as a list), text files such as READMEs and changelogs, also when they are compressed (`changelog.Debian.gz`), and pictures. PDF and office files go to their programs.

It has no JavaScript and draws modern layouts (CSS 3) only in part, so the large handbooks open in Firefox instead.

!!! planned "Planned"
    A table of contents of all installed documentation, full-text search, manual pages and bookmarks.

## The handbooks

The **Help** slot of the Front Panel opens this handbook, the *amadeOS User's Handbook*. Its drawer lists:

| Entry | What it is |
|---|---|
| **amadeOS User's Handbook** | This book. It is installed on the computer, so it opens in Firefox without a network. |
| **Application Developer's Handbook** | How the amade applications of Part V are made, and how to write your own with amade-commons (chapter 63). |
| **Game Developer's Handbook** | How the games of chapter 49 are made, and how to write your own with the amade game engine. |
| **Documentation Viewer** | The documentation of the installed packages, see above. |

The handbook is also on the web, at `https://datazuul.github.io/amadeos/`, always in its newest version. In Firefox, ++ctrl+f++ searches the page and the search box at the top searches the whole book.
