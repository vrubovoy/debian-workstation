# Configuration

## Managed user configuration

User configuration is deployed with GNU Stow.

| Component | Repository path | Target |
|---|---|---|
| i3 | `dotfiles/i3/.config/i3/config` | `~/.config/i3/config` |
| i3status | `dotfiles/i3status/.config/i3status/config` | `~/.config/i3status/config` |
| Kitty | `dotfiles/kitty/.config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| Rofi | `dotfiles/rofi/.config/rofi/` | `~/.config/rofi/` |
| Dunst | `dotfiles/dunst/.config/dunst/` | `~/.config/dunst/` |
| Picom | `dotfiles/picom/.config/picom/` | `~/.config/picom/` |

## Managed system configuration

System configuration is copied explicitly by the installation scripts and is
not managed through GNU Stow.

| Component | Repository path | Target |
|---|---|---|
| LightDM greeter | `system/lightdm/lightdm-gtk-greeter.conf` | `/etc/lightdm/lightdm-gtk-greeter.conf` |
| LightDM theme | `system/lightdm/themes/GraphiteBlue-LightDM/` | `/usr/share/themes/GraphiteBlue-LightDM/` |

## Session helpers

Small desktop operations that require logic beyond a single application command
are implemented as standalone scripts.

| Purpose | Repository path | User command |
|---|---|---|
| Wallpaper | `scripts/session/wallpaper.sh` | `workstation-wallpaper` |
| Screen locking | `scripts/session/lock.sh` | `workstation-lock` |
| Idle policy | `scripts/session/idle.sh` | `workstation-idle` |
| Audio control | `scripts/session/volume.sh` | `workstation-volume` |
| Brightness control | `scripts/session/brightness.sh` | `workstation-brightness` |
| Media control | `scripts/session/media.sh` | `workstation-media` |
| Screenshots | `scripts/session/screenshot.sh` | `workstation-screenshot` |
| Session/power menu | `scripts/session/power-menu.sh` | `workstation-power-menu` |

### Screen locking

The workstation uses `i3lock` as the X11 screen locker and `xss-lock` as the
integration layer between i3lock, XScreenSaver and systemd-logind.

Manual locking:

`Super + L`

Automatic policy:

- 10 minutes idle: lock session.
- 15 minutes idle: power displays off.
- Suspend/hibernate: lock before entering sleep.

`xss-lock --transfer-sleep-lock` is used so that system sleep cannot occur
before the graphical session is secured.

### Wallpaper

The default wallpaper is stored at:

`assets/wallpapers/default.jpg`

At session startup, `workstation-wallpaper` applies it using Feh.

If the asset is unavailable, the script falls back to the Graphite Blue base
color `#111318`.

Feh is invoked with `--no-fehbg`; therefore `~/.fehbg` is intentionally not
used or managed.

### Desktop OSD

Volume, microphone and brightness changes are displayed through Dunst.

The helper scripts use Dunst stack tags so repeated hardware-key presses update
the current notification rather than creating multiple notifications.

Volume is controlled through WirePlumber `wpctl`.

Brightness is controlled through `brightnessctl`.

Media keys are handled through Playerctl and MPRIS. `playerctld` runs during the
i3 session so commands are directed to the most recently active media player.

### Screenshots

Screenshots are captured using the X11-native `maim` utility.

Supported modes:

- `area` — interactive rectangular selection;
- `window` — currently focused X11 window;
- `screen` — complete X11 desktop.

Screenshots are simultaneously:

- written to `~/Pictures/Screenshots`;
- copied to the X11 clipboard as PNG;
- reported through Dunst.

### Power menu

Session and power operations are exposed through a Rofi menu.

Available actions:

- lock;
- suspend;
- logout;
- reboot;
- power off.

Logout, reboot and power-off operations require explicit confirmation.

Suspend relies on the existing `xss-lock` / systemd-logind integration to
secure the session before sleeping.

## Desktop infrastructure

### NetworkManager

Physical network interfaces are managed by NetworkManager.

`/etc/network/interfaces` contains only the loopback interface.

Network connection profiles and credentials are deliberately not tracked by
Git.

### Audio

The workstation uses the Debian `pipewire-audio` stack:

- PipeWire
- PipeWire PulseAudio compatibility server
- PipeWire ALSA plugin
- WirePlumber
- PipeWire Bluetooth support

No custom PipeWire or WirePlumber configuration is currently required.

### Bluetooth

BlueZ provides the Bluetooth stack.

Blueman provides the graphical device manager and i3bar tray applet.

### PolicyKit

`mate-polkit` provides the graphical authentication agent required by
applications running under i3.

### Neovim

Neovim is the default terminal text editor.

Configuration:

`dotfiles/nvim/.config/nvim/`

The configuration intentionally uses only built-in Neovim functionality.

No external plugin manager or plugin dependencies are required by the base
workstation.

Structure:

- `init.lua` — configuration entrypoint.
- `lua/workstation/options.lua` — editor behaviour and defaults.
- `lua/workstation/keymaps.lua` — workstation-specific mappings.
- `lua/workstation/autocmds.lua` — automatic editor behaviour.
- `colors/graphite-blue.lua` — native Graphite Blue colorscheme.

Default indentation is four spaces.

Project-specific formatting is controlled through Neovim's built-in
EditorConfig support whenever a `.editorconfig` file is present.

The X11 clipboard is exposed to Neovim through `xclip`.

Persistent undo and swap files remain enabled for editing safety.

### Shell

Fish is the default interactive shell.

Configuration is split into:

- `config.fish` — shell initialization.
- `conf.d/10-environment.fish` — environment and PATH.
- `conf.d/20-colors.fish` — Graphite Blue shell colors.
- `conf.d/30-abbreviations.fish` — general abbreviations.
- `conf.d/90-development-abbreviations.fish` — optional development shortcuts.
- `functions/` — reusable Fish functions.

Starship provides a deliberately minimal one-line prompt containing only:

- current directory;
- Git branch;
- Git working-tree state;
- command prompt character.

The right-side prompt and command duration are intentionally disabled.

Fastfetch is displayed as the Fish greeting. Kitty uses its native graphics
protocol to render `~/.config/fastfetch/logo.png`.

### Yazi

Yazi is the primary terminal file manager.

Configuration:

`dotfiles/yazi/.config/yazi/`

Files:

- `yazi.toml` — file-manager behaviour and preview settings.
- `keymap.toml` — workstation-specific bindings layered over Yazi defaults.
- `theme.toml` — Graphite Blue UI.

Yazi is installed from its official stable APT repository.

Preview support is provided by:

- Kitty graphics protocol — images;
- FFmpeg — video thumbnails;
- Poppler — PDF previews;
- 7-Zip — archive previews;
- jq — JSON;
- resvg — SVG;
- ImageMagick — additional image formats.

The workstation deliberately disables Yazi's built-in Nerd Font icons because
the terminal font is Ubuntu Mono Bold.

The Fish `y` wrapper starts Yazi and changes the shell working directory to the
directory selected when Yazi exits.

On Debian, `fd-find` provides `/usr/bin/fdfind`, while Yazi expects `fd`.
The workstation therefore exposes `~/.local/bin/fd` as a compatibility symlink
to `/usr/bin/fdfind`.

### Firefox

Firefox ESR is installed from Debian Stable and used as the default web
browser.

System-wide reproducible settings are stored in:

`system/firefox/policies.json`

and installed to:

`/etc/firefox/policies/policies.json`

The policy configuration:

- disables telemetry uploads;
- disables Firefox Studies;
- removes sponsored Firefox Home content;
- removes feature and extension recommendations;
- skips onboarding messages;
- disables built-in generative-AI features by default.

Policies deliberately avoid controlling personal browser behaviour such as:

- saved passwords;
- session restoration;
- download location;
- Firefox Sync;
- search engine;
- browsing history;
- extensions.

Firefox profiles under `~/.mozilla/firefox/` are user data and are never
tracked by the workstation repository.

### GTK

User configuration:

- `~/.gtkrc-2.0`
- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-3.0/gtk.css`
- `~/.config/gtk-4.0/settings.ini`
- `~/.config/gtk-4.0/gtk.css`

The system uses:

- Adwaita as the icon theme;
- Adwaita-dark as the GTK 3 base theme;
- Ubuntu Bold as the UI font;
- Graphite Blue user CSS for workstation colors.

### Qt

Qt does not maintain a separate workstation color scheme.

Qt 5 and Qt 6 applications use the GTK platform-theme plugins.

The graphical X11 session exports:

`QT_QPA_PLATFORMTHEME=gtk3`

through `~/.xsessionrc`.

This setting deliberately lives outside Fish so applications launched directly
from i3 or Rofi receive it as well.

### Desktop settings

`scripts/configure/appearance.sh` applies equivalent GSettings values for
applications which use desktop-wide GNOME interface settings.

## Git

Git behaviour is configured through:

`~/.config/git/config`

Personal identity is stored separately in:

`~/.gitconfig.local`

The local file is deliberately not part of the workstation repository.

The base configuration provides:

- `main` as the default branch;
- Neovim as Git editor;
- fast-forward-only pulls;
- automatic upstream setup on first push;
- automatic remote pruning;
- histogram diffs;
- `zdiff3` conflict markers;
- rerere conflict-resolution reuse.

## SSH

OpenSSH client configuration is tracked through:

`~/.ssh/config`

Private keys and `known_hosts` are never tracked.

Debian Xsession owns the lifecycle of the SSH agent. Fish does not start an
SSH agent.

`AddKeysToAgent yes` allows successfully used keys to enter the session agent.

## GnuPG

GnuPG uses `gpg-agent` with graphical GTK pinentry.

The public workstation configuration controls only agent behaviour.

Actual GPG keys and trust databases are private user data.

Git commit signing is enabled only through machine-local Git configuration
after a signing key has been created.

## Dotfiles

User configuration files are stored under `dotfiles/` and deployed into the
home directory with GNU Stow.

Each top-level directory inside `dotfiles/` is an independent Stow package.

Examples:

- `dotfiles/i3/`
- `dotfiles/kitty/`
- `dotfiles/fish/`
- `dotfiles/nvim/`
- `dotfiles/yazi/`
- `dotfiles/git/`
- `dotfiles/ssh/`

A package mirrors the target directory structure below `$HOME`.

For example:

    dotfiles/i3/.config/i3/config

is deployed as:

    ~/.config/i3/config


### GNU Stow

All workstation Stow packages must be installed with `--no-folding`.

The standard command is:

    cd ~/Projects/debian-workstation/dotfiles
    stow --no-folding -t "$HOME" <package>

Directory folding is deliberately disabled.

Without `--no-folding`, GNU Stow may replace an entire target directory with a
single symbolic link. For example:

    ~/.config/i3
        -> ~/Projects/debian-workstation/dotfiles/i3/.config/i3

This repository instead expects normal directories to remain real directories
and only managed files to become symbolic links:

    ~/.config/i3/
    └── config
        -> ~/Projects/debian-workstation/dotfiles/i3/.config/i3/config

This makes the resulting home directory easier to inspect and prevents
application-generated files from being written into the workstation
repository unintentionally.

The rule is particularly important for directories which can contain private
or mutable user data.

For example, `~/.ssh` may contain:

- private keys;
- public keys;
- `known_hosts`;
- control sockets.

The repository manages only:

    ~/.ssh/config

Similarly, `~/.gnupg` contains private keys and runtime state. The repository
may manage selected configuration files, but the directory itself must never
become a symbolic link into the repository.


### Updating managed files

Managed configuration files should normally be edited directly in the
repository.

For example:

    ~/Projects/debian-workstation/dotfiles/i3/.config/i3/config

Because the corresponding file under `$HOME` is a symbolic link, changes are
immediately visible to the application.

Application-specific reload or restart procedures are documented in the
corresponding sections of this document.


### Adding a new Stow package

A new package should reproduce the final path relative to `$HOME`.

For example, to manage:

    ~/.config/example/config.toml

create:

    dotfiles/example/.config/example/config.toml

and deploy it with:

    cd ~/Projects/debian-workstation/dotfiles
    stow --no-folding -t "$HOME" example


### Removing a Stow package

To remove links created by a package:

    cd ~/Projects/debian-workstation/dotfiles
    stow -D -t "$HOME" <package>

Removing a Stow package removes its managed symbolic links but does not remove
unrelated user files from the target directories.


### Private and runtime data

The workstation repository contains reproducible configuration only.

Private credentials, cryptographic keys, caches and application runtime state
must never be stored under `dotfiles/`.

Examples of data which must remain outside the repository include:

- SSH private keys;
- GPG private keys and trust databases;
- Git credentials and authentication tokens;
- browser profiles;
- application caches;
- logs;
- temporary files;
- generated sockets and lock files.