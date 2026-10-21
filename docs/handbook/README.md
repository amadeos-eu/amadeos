# amadeOS User's Handbook

Why amadeOS, how to install it, how to use and administer it. Published at
<https://datazuul.github.io/amadeos/>; on amadeOS the package `amadeos-handbook` installs it to
`/usr/share/doc/amadeos-handbook/html`, and *Help → amadeOS User's Handbook* in the Front Panel opens it
in the web browser. Set up like the [Amade Game Developer's Handbook](https://github.com/datazuul/amade-game-engine/tree/main/docs/handbook).

## Writing

- One Markdown file per chapter in `chapters/`, numbered by part: `0x` part I (why), `1x` part II
  (getting amadeOS), `2x` part III (the desktop), `3x` part IV (Style Manager), `4x` part V
  (applications), `5x` part VI (administration), `6x` part VII (under the hood), `appendix-*.md`.
  The order of the book is the `nav` in `mkdocs.yml`; `chapters/plan.md` lists the chapters still to
  come, and a chapter moves from there into the `nav` when it is written.
- Pictures go to `chapters/images/<chapter>/`, as JPEG (full-desktop PNGs are several MB).
- The recurring boxes (styles in `chapters/stylesheets/amadeos.css`):

  | Box | Markdown | Use |
  |---|---|---|
  | Planned | `!!! planned "Planned"` | A feature of the ROADMAP that does not exist yet, with its milestone. **When the feature is built, its PR rewrites the box into ordinary text**; search the chapters for `!!! planned`. |
  | Coming from Windows or macOS | `!!! switching "Coming from Windows or macOS"` | Where the familiar thing is. |
  | CDE heritage | `!!! cde "CDE heritage"` | Which CDE program a part follows, and the differences. |
  | Under the hood | `??? hood "Under the hood"` | Files, settings and commands, folded. |
  | Your data | `!!! sovereignty "Your data"` | Where an application keeps data and what it sends. |

- Keys with `++ctrl+q++` (pymdownx.keys), menu paths as *File → Open*.
- English first; the other desktop languages may follow.

## Building locally

```bash
cd docs/handbook
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
.venv/bin/mkdocs serve           # http://127.0.0.1:8000, reloads on every save
.venv/bin/mkdocs build --strict  # what CI runs
scripts/package-handbook.sh      # (from the repository root) the package amadeos-handbook into build/
```

`mkdocs-offline.yml` is the variant in the package: links to `.html` files, the `offline` plugin for
search without a server and the `privacy` plugin, which stores fonts and scripts next to the pages.
`build-image.sh` and `buildDistribution.sh` build the package into the image.

## Publishing

`.github/workflows/handbook.yml` builds every pull request that touches `docs/handbook` and publishes
`main` to GitHub Pages. Pages must be set to *GitHub Actions* once, in the repository's
*Settings → Pages → Build and deployment → Source*.

## Screenshots

Screenshots are made by scripts, so they can be renewed whenever the desktop changes, always in the
same size (1280×800), theme (Warm Motif) and language (English):

```sh
docs/handbook/screenshots/shoot.sh --install          # all scenes, on a throw-away machine as root
docs/handbook/screenshots/shoot.sh drawers windows    # only these scenes
```

`shoot.sh` starts an **Xvfb** screen, the amadeOS session from the installed packages and the programs
with the invented demo home of `screenshots/home/` (user Alex Example), drives them with `xdotool` and
saves the pictures with `import` as `chapters/images/<chapter>/<name>.jpg`. The scenes, and the screen
coordinates they click, are in `screenshots/scenes.sh`; when the Front Panel changes, adjust its
`PANEL_*` values. `--install` installs `config/packages.chroot/*.deb` (from `buildDistribution.sh`),
creates the demo user `alex` and bind-mounts a live kernel command line over `/proc/cmdline` for the
installer pictures, so run it only in a container or virtual machine. The installer runs with
`AMADEOS_INSTALL_COMMAND` pointing at `fake-install.sh` of a checkout of amadeos-installer next to
this repository, and with a pretend `lsblk` (`screenshots/fake-bin/`) that shows one empty disk:
nothing is ever written to a disk. Needs `xvfb`, `xdotool`, `x11-utils` and `imagemagick`.

The boot menu of the stick and GRUB are still missing; they will be taken in **QEMU** without a
window, driven through the monitor (`sendkey`, `screendump`).
