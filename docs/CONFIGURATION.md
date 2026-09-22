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
| `packages/external.txt` | installed | pinned `.deb` from GitHub |

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
The original of every replaced file is kept once as `*.debian-workstation.bak`.

- `/etc/apt/sources.list.d/debian.sources`: Debian 13 with contrib, non-free
  and non-free-firmware. Debian entries in an old one-line
  `/etc/apt/sources.list` are commented out (after a backup); other entries
  there are left alone.
- `/etc/network/interfaces`: loopback only; NetworkManager owns everything else.
- `/etc/default/keyboard`: US/RU layouts, `Alt+Space` to switch and Compose on
  Right Alt, for the console, LightDM and X alike.
- `/etc/X11/xorg.conf.d/90-workstation-input.conf`: tap to click and natural
  scrolling on touchpads, slightly slower adaptive acceleration for mice.
- `/etc/firefox/policies/policies.json`: generated from the repository file
  plus the extensions chosen on this machine (see below).

### Commands

| Command | Does |
|---|---|
| `workstation-lock` | Lock the screen (i3lock) |
| `workstation-power-menu` | Lock, suspend, log out, reboot, power off |
| `workstation-screenshot area\|window\|screen` | Save to `~/Pictures/Screenshots` and copy to the clipboard |
| `workstation-clipboard` | Pick from the clipboard history (`start`: start CopyQ) |
| `workstation-volume up\|down\|mute\|mic-mute` | Volume with an on-screen display |
| `workstation-brightness up\|down` | Backlight with an on-screen display |
| `workstation-wallpaper` | Set the wallpaper |

`~/.xsessionrc` puts `~/.local/bin` on the session `PATH`, so i3 calls them by
name. Debian's `fd-find` names its command `fdfind`, so the installer adds
`~/.local/bin/fd` too.

## Design

- **Debian stable first.** Only three things come from upstream: Yazi from its
  official APT repository, and Onefetch and VSCodium as `.deb` releases pinned
  in `packages/external.txt`. The installer checks each download against its
  expected package name and version, and against the published SHA-256 file
  where there is one (VSCodium).
- **One theme source.** GTK 3 is Adwaita-dark and GTK 4 is Adwaita, each with a
  Graphite Blue `gtk.css`. Qt 5 and 6 follow GTK through
  `QT_QPA_PLATFORMTHEME=gtk3`, and the same values are set as GSettings. Icon
  glyphs in the terminal come from Kitty's built-in Nerd Font fallback, so no
  patched font is needed.
- **Firefox through policies**, not a profile `user.js`. The policies turn off
  telemetry, studies, sponsored content, online Firefox Suggest and the AI
  features, and turn on DNS over HTTPS (Cloudflare, falling back to system
  DNS). Optional extensions are picked with
  `scripts/configure/firefox-extensions.sh`; the choice is kept in
  `/etc/debian-workstation/firefox-extensions` and Firefox installs them on
  its next start.
- **Locking.** `workstation-lock` is the only locker. `xss-lock` runs it after
  10 minutes idle and before suspend, and displays turn off after 15 minutes.
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
- **Pinned release:** change the version in `packages/external.txt`.
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
