# amadeOS Drop-In Debian Packages (`config/packages.chroot/`)

Place custom `.deb` packages for user-space applications (e.g. `amade-pad`, `amade-fm`, `amade-calc`, etc.) in this directory.

## How it works:
1. **Full ISO Build (`./build.sh`):**
   Debian `live-build` natively inspects `config/packages.chroot/` during the chroot package installation stage and installs all `*.deb` packages automatically with dependency resolution.
2. **Incremental Quick Build (`AMADEOS_QUICK=1 ./build.sh`):**
   `scripts/build-image.sh` installs all `*.deb` packages directly into `$BUILD_ROOT/chroot` using `dpkg -i` and `apt-get install -f -y` before rebuilding squashfs.

## Package Requirements for Independent Applications:
- Installs executable launcher in `/usr/bin/<app-name>`
- Installs Freedesktop desktop entry in `/usr/share/applications/<app-name>.desktop` with appropriate `Categories=...`
- Installs application icons in `/usr/share/icons/hicolor/<size>/apps/<app-name>.png` or `/usr/share/pixmaps/<app-name>.png`
- amadeOS automatically parses `.desktop` files and populates CDE Front Panel drawers dynamically!

