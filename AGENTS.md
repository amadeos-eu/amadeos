# AGENTS.md

Architectural decisions for people and coding agents working on amadeOS. Read this before adding a
module or deciding which repository a piece of code belongs in. The reasons behind the larger choices
(kernel, Debian, X11, Java) are in [`CONCEPT.md`](CONCEPT.md); status and plans are in
[`ROADMAP.md`](ROADMAP.md). When you make a decision of this kind, add it here.

## Repository family and where code goes

| Repository | Holds | Rule |
|---|---|---|
| `amadeos` | The live image: live-build configuration, hooks, package lists, image scripts, QEMU scripts, documentation | No Java, no Gradle. Image settings live in one place (hooks in `config/hooks/normal`). |
| `amadeos-system` | System components, one Gradle module and one Debian package per module: `base`, `wm`, `panel-cde`, `dm`, `session`, `style`, `logviewer`, `print`, `sysinfo`, and the package-management modules (`packages`, `package-updates`, `appstore`) | Everything that is **Debian-specific or only makes sense together with amadeOS**: the desktop, the display manager, anything that talks to apt, systemd, logind, polkit, CUPS or NetworkManager, and the tools that administer the system. |
| `amade-commons` | Shared library for applications: themes, Motif look-and-feel, XDG directories, keyring, start-up | **Operating-system neutral.** It must not depend on Debian, apt, systemd or amadeOS services. |
| `amade-<app>` (pad, mail, files, web, calendar, audio, video, fractals, imagescan, writepad) | Standalone end-user applications, each in its own repository | They should **run on other operating systems too**. They depend on `amade-commons` only, never on `amadeos-system`. |
| `amadeos-installer` | The installer assistant and the `amadeos-install` script | Own repository (it is a build-time and image concern with its own release cycle). |

**Names follow the same split:** `amadeos-*` (repositories, Debian packages, commands) is
operating-system specific and belongs to `amadeos-system`, the image or the installer; `amade-*` is
portable (applications and `amade-commons`). Renamed 2026-10-18 from `amade-system` and
`amade-wm`, `amade-dm`, `amade-session`, `amade-panel-cde`, `amade-style`, `amade-logviewer`,
`amade-print`, `amade-sysinfo`; the new packages declare the old names in Conflicts/Replaces. A module
whose script has its package's name (`amadeos-session`, `amadeos-dm`) keeps the jar launcher in
`/usr/libexec/<package>`.

**Java packages** of every repository start with `eu.amadeos`. Applications (`amade-<app>`) live in
`eu.amadeos.apps.<app>.*` (`eu.amadeos.apps.pad.*`, `eu.amadeos.apps.mail.*`, …); the shared library
is `eu.amadeos.commons.*`, and system modules and the installer use `eu.amadeos.<module>.*`
(`eu.amadeos.wm.*`, `eu.amadeos.installer.*`, …). The sub-package structure below that stays as it is. The Gradle group of the applications is `eu.amadeos`; amade-commons keeps
`com.github.datazuul` because JitPack derives it from the repository. Renamed 2026-10-18 from
`org.datazuul.amadeos`.

The test for a new piece of code: *would it still make sense on another operating system?* If yes, it
is an application (own repository, on `amade-commons`). If it only works on Debian or only has a
meaning inside amadeOS, it is a module of `amadeos-system`. Direction of dependency:
applications → `amade-commons`; `amadeos-system` modules → `base` (and `amade-commons`); never
the other way round, and applications never depend on `amadeos-system`.

Examples: the text editor, mail client and file manager are applications. Package management
(apt library, update window, app store, the status cell) is Debian-specific and therefore
`amadeos-system`, even though it has a GUI. `amade-commons` therefore has no package-management code.

## amadeos-system conventions

- **One module, one Debian package** (`amadeos-<module>`), each a fat jar under `/opt/<package>/` with a
  launcher `/usr/bin/<package>`. A module's `packaging/root` mirrors the file system (files under
  `etc/` are conffiles), `packaging/debian` holds the maintainer scripts. The shared library `base`
  is bundled into every package; there is no shared base package. Library modules such as `packages`
  follow the same rule.
- **Modules do not depend on each other sideways** except through a library module (`base`,
  `packages`). Programs that the panel launches (Tools drawer, `.desktop` files) are started as
  separate processes, not linked in.
- **The panel knows no program by name** and the window manager recognises the panel only by its EWMH
  window type (`_NET_WM_WINDOW_TYPE_DOCK`, in practice by its strut, because AWT overwrites the type at
  map time). A second panel provides the virtual package `amadeos-panel`.
- **Status indicators** are `StatusCell`s in the panel's status slot (up to four), not a system tray.
- **Privileged work** goes through a small helper started with `pkexec` and a polkit action (as
  `amadeos-install` does), never through a long-running root daemon written in Java. Prefer a shell
  script for the helper so root runs no Java. No passwords on command lines where avoidable.
- **Settings** are files under `$XDG_CONFIG_HOME/amadeos` (user) and `/etc/amadeos` (system), read by
  every component; no registry or settings daemon.
- **Xlib access** only from the window manager's event-loop thread; native access through JNA
  (X11, PAM) or FFM, with `Enable-Native-Access: ALL-UNNAMED` in the jar manifest of programs that need it.
- **Look and feel:** applications and tools follow the theme chosen in the Style Manager
  (`DesktopTheme` from `amade-commons`) and the CDE style; icons come from the NsCDE icon theme.
- **Texts** are internationalised (English, Deutsch, Français, Español, Italiano).

## Image and packaging

- Debian 13 *trixie*, built with live-build; the kernel and Debian userland are not replaced.
- Everything amade-specific reaches the image as a `.deb` (`config/packages.chroot/`, later from the
  amadeOS repository, see ROADMAP M16). The image build never runs Gradle.
- Debian security and `trixie-updates` archives are configured in the image so `apt` receives fixes.
- Image builds need root: `sudo ./build.sh` (a run without sudo fails on root-owned files).
- Updates go through apt only (no Flatpak or Snap in scope). The user stays in control: checking and
  notifying are automatic, installing is the user's action (or an opt-in setting for security updates).

## Working rules

- Do not mark a milestone done from a build alone; record command, environment and observed result
  (see ROADMAP "Working agreement").
- Code reads like the code around it: same naming, comment density and idiom.
- Tests run in Gradle in CI. The window manager's X11 integration tests start `Xvfb` on display `:98`;
  a stale X server there makes them fail with wrong screen sizes (kill it first).
- Licence is EUPL-1.2 for all repositories.
