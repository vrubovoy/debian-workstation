# Configuration

How the repository maps onto the system, the choices behind it, and how to
change it.

## Where files go

| In the repository | On the system | How |
|---|---|---|
| `dotfiles/<program>/…` | `$HOME/…` | GNU Stow symlinks |
| `system/…` | `/…` | copied as root |
| `scripts/session/<name>.sh` | `~/.local/bin/workstation-<name>` | symlink |
| `packages/{base,desktop,applications,development}.txt` | installed | APT |
| `packages/external.txt` | offered one by one | pinned release from GitHub |

For example, `dotfiles/i3/.config/i3/config` becomes `~/.config/i3/config`,
and `system/etc/lightdm/lightdm-gtk-greeter.conf` becomes
`/etc/lightdm/lightdm-gtk-greeter.conf`.

### Dotfiles

Each directory under `dotfiles/` is a Stow package, linked with
`--no-folding`: every file is its own symlink into the repository and every
directory stays a real directory. That keeps `~/.ssh` and `~/.gnupg` real
directories, so keys created in them can never end up in the repository.

Editing a file in the repository changes the live configuration at once;
reload the program to see it (`Super+Ctrl+R` for i3). A file that is already in
the way when the installer runs is moved to `*.debian-workstation.bak`.

### System files

Files under `system/` are copied, not linked, because they belong to root.
After changing one, run `./install.sh` (or `sudo scripts/install/system.sh`).
The first time the installer replaces a file, it keeps the system's version as
`*.debian-workstation.bak` and records the path in
`/etc/debian-workstation/managed-files`; later runs overwrite it without new
backups.

- `/etc/apt/sources.list.d/debian.sources`: Debian 13 with contrib, non-free
  and non-free-firmware. Debian entries in an old one-line
  `/etc/apt/sources.list` are commented out (after a backup); other entries
  there are left alone.
- `/etc/network/interfaces`: loopback only; NetworkManager owns everything else.
- `/etc/default/keyboard`: US/RU layouts, `Alt+Space` to switch and Compose on
  Right Alt, for the console, LightDM and X alike.
- `/etc/X11/xorg.conf.d/90-workstation-input.conf`: tap to click and natural
  scrolling on touchpads, slightly slower adaptive acceleration for mice.
- `/etc/firefox-esr/policies/policies.json`: generated from the repository
  file plus the extensions chosen on this machine (see below).
- `/usr/lib/firefox-esr/workstation.cfg` with `defaults/pref/autoconfig.js`:
  Firefox's AutoConfig, which applies `workstation-newtab.css` next to it to
  every profile.
- `/etc/default/grub.d/workstation.cfg`: the GRUB menu over the wallpaper.
  The installer writes the image to `/boot/grub/workstation.jpg` (GRUB reads
  only baseline JPEGs) and runs `update-grub`.
- `/usr/share/locale/en/LC_MESSAGES/lightdm-gtk-greeter.mo`: turns the login
  form's hints into `login` and `password`. It applies with an English system
  locale; other languages keep the greeter's own translation.

### Commands

| Command | Does |
|---|---|
| `workstation-lock` | Lock the screen (i3lock over the wallpaper) |
| `workstation-power-menu` | Tiles for power off, reboot, suspend, lock and log out; the first, second and last confirm with a 5-second countdown |
| `workstation-screenshot area\|window\|screen` | Save to `~/Pictures/Screenshots` and copy to the clipboard |
| `workstation-clipboard` | Pick from the clipboard history (`start`: start CopyQ) |
| `workstation-volume up\|down\|mute\|mic-mute` | Volume with an on-screen display |
| `workstation-brightness up\|down` | Laptop backlight, or the monitors over DDC/CI on a desktop, with an on-screen display |
| `workstation-wallpaper` | Set the wallpaper |

`~/.xsessionrc` puts `~/.local/bin` on the session `PATH`, so i3 calls them by
name. Debian's `fd-find` names its command `fdfind`, so the installer adds
`~/.local/bin/fd` too.

## Design

- **Debian stable first.** Yazi comes from its official APT repository. The
  other upstream software is optional: VSCodium, Onefetch and AmneziaVPN are
  offered one by one by `scripts/configure/external-packages.sh`, pinned in
  `packages/external.txt` by URL and SHA-256. A download that does not match
  its checksum is refused, so a release is exactly what the repository says
  it is. AmneziaVPN has no `.deb`; its own installer runs headless into
  `/opt/AmneziaVPN`.
- **One theme source.** GTK 3 is Adwaita-dark and GTK 4 is Adwaita, each with a
  Graphite Blue `gtk.css`. Qt 5 and 6 follow GTK through
  `QT_QPA_PLATFORMTHEME=gtk3`, and the same values are set as GSettings. Icon
  glyphs in the terminal come from Kitty's built-in Nerd Font fallback, so no
  patched font is needed.
- **Firefox through policies**, not a profile `user.js`. The policies turn off
  telemetry, studies, sponsored content, online Firefox Suggest and the AI
  features, and turn on DNS over HTTPS (Cloudflare, falling back to system
  DNS). The dark theme is the default, and with Firefox Home emptied the
  search field sits in the middle of a new tab. Optional extensions are
  picked with `scripts/configure/firefox-extensions.sh`; the choice is kept in
  `/etc/debian-workstation/firefox-extensions` and Firefox installs them on
  its next start.
- **Locking.** `workstation-lock` is the only locker. It shows the wallpaper,
  fitted to each monitor once and cached in `~/.cache/workstation`. `xss-lock`
  runs it after 10 minutes idle and before suspend, and displays turn off
  after 15 minutes.
- **Focus.** The focused window, the Rofi menus and the LightDM form share the
  look of a focused text field: an accent border and a faint ring around it.
  For windows the ring is picom's shadow, drawn only around the focused one.
- **Launcher.** Rofi would show applications whose icon is missing with a
  blank icon, so the installer hides them for the user with `Hidden=true`
  entries in `~/.local/share/applications`. Run `./install.sh` again after
  installing new software.
- **Clipboard.** CopyQ keeps the last 200 clipboard items but ignores the
  mouse selection (PRIMARY). `workstation-clipboard start` applies these
  settings at every login, so they always match the repository.
- **No secrets in Git.** Name, email and signing key live in
  `~/.gitconfig.local`; SSH and GPG keys, `known_hosts` and browser profiles
  stay on the machine. `scripts/configure/` creates them locally.

## Common changes

- **Package:** add the name to the matching `packages/*.txt` and run
  `./install.sh`. CI checks that every name resolves on Debian 13.
- **Configuration file:** put it under `dotfiles/<program>/` at its path
  relative to `$HOME` and run `./install.sh`; a new directory becomes a new
  Stow package automatically.
- **System file:** put it under `system/` at its absolute path.
- **Command:** add an executable `scripts/session/<name>.sh`; after
  `./install.sh` it is available as `workstation-<name>`.
- **Pinned release:** update the version, URL and SHA-256 in
  `packages/external.txt`; the file header shows how to get each.
- **Wallpaper:** replace `assets/wallpapers/default.jpg`, then run
  `workstation-wallpaper`.
- **Firefox extension:** add its ID and addons.mozilla.org slug to
  `packages/firefox-extensions.txt`, then run
  `scripts/configure/firefox-extensions.sh`.
- **VSCodium extension:** add it to `packages/vscodium-extensions.txt` (it
  must exist on Open VSX).
- **CPU temperature in the bar:** it depends on the machine; see the end of
  `dotfiles/i3status/.config/i3status/config`.

## Checks

`.github/workflows/lint.yml` runs on every push. It checks shell scripts
(syntax, ShellCheck, executable bit); Fish, JSON, JSONC, TOML and YAML syntax;
the Rofi theme and i3 config; whitespace, line endings and final newlines. It
also resolves every package list in a Debian 13 container with the
installer's own repository setup.
