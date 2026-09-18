# Configuration

This document is a reference for what the repository manages and where each
configuration is deployed. Architectural rationale belongs in
`ARCHITECTURE.md`; installation order belongs in `INSTALL.md`.

## Dotfiles

User configuration files are stored under `dotfiles/` and deployed into the
home directory with GNU Stow. Each top-level directory inside `dotfiles/` is an
independent Stow package and mirrors the final path relative to `$HOME`.

For example:

    dotfiles/i3/.config/i3/config

is deployed as:

    ~/.config/i3/config

### GNU Stow

All workstation Stow packages are installed with `--no-folding`:

    cd ~/Projects/debian-workstation/dotfiles
    stow --no-folding -t "$HOME" <package>

Directory folding is deliberately disabled. Normal directories remain real
directories while repository-managed files become symbolic links.

Expected result:

    ~/.config/i3/
    └── config
        -> <repository>/dotfiles/i3/.config/i3/config

rather than:

    ~/.config/i3
        -> <repository>/dotfiles/i3/.config/i3

This is particularly important for `~/.ssh` and `~/.gnupg`, which may later
contain private keys, host databases, sockets and other mutable data.

The repository provides `scripts/install/stow-dotfiles.sh` to deploy the current
set of Stow packages consistently.

### Updating managed files

Edit managed files in the repository. Because the file under `$HOME` is a
symbolic link, the application sees the updated content immediately. Apply the
component-specific reload/restart step when required.

### Adding a Stow package

To manage `~/.config/example/config.toml`, create:

    dotfiles/example/.config/example/config.toml

and deploy it with:

    stow --no-folding -t "$HOME" example

### Removing a Stow package

Use:

    stow -D -t "$HOME" <package>

Removing a package removes its managed links; unrelated files in the target
directories remain untouched.

### Private and runtime data

Do not place credentials, cryptographic keys, caches or mutable application
state under `dotfiles/`. Examples include SSH/GPG private keys, `known_hosts`,
browser profiles, authentication tokens, caches, logs, sockets and lock files.

## Managed user configuration

| Component | Repository path | Target |
|---|---|---|
| Dunst | `dotfiles/dunst/.config/dunst/` | `~/.config/dunst/` |
| Fastfetch | `dotfiles/fastfetch/.config/fastfetch/` | `~/.config/fastfetch/` |
| Fish | `dotfiles/fish/.config/fish/` | `~/.config/fish/` |
| Git | `dotfiles/git/.config/git/config` | `~/.config/git/config` |
| GnuPG agent | `dotfiles/gnupg/.gnupg/gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` |
| GTK | `dotfiles/gtk/` | `$HOME` |
| i3 | `dotfiles/i3/.config/i3/config` | `~/.config/i3/config` |
| i3status | `dotfiles/i3status/.config/i3status/config` | `~/.config/i3status/config` |
| Kitty | `dotfiles/kitty/.config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| Neovim | `dotfiles/nvim/.config/nvim/` | `~/.config/nvim/` |
| Picom | `dotfiles/picom/.config/picom/` | `~/.config/picom/` |
| Rofi | `dotfiles/rofi/.config/rofi/` | `~/.config/rofi/` |
| SSH client | `dotfiles/ssh/.ssh/config` | `~/.ssh/config` |
| Starship | `dotfiles/starship/.config/starship.toml` | `~/.config/starship.toml` |
| X session | `dotfiles/xsession/.xsessionrc` | `~/.xsessionrc` |
| Yazi | `dotfiles/yazi/.config/yazi/` | `~/.config/yazi/` |

## Managed system configuration

System configuration is copied explicitly rather than managed with Stow.

| Component | Repository path | Target |
|---|---|---|
| LightDM greeter | `system/lightdm/lightdm-gtk-greeter.conf` | `/etc/lightdm/lightdm-gtk-greeter.conf` |
| LightDM theme | `system/lightdm/themes/GraphiteBlue-LightDM/` | `/usr/share/themes/GraphiteBlue-LightDM/` |
| Network interfaces | `system/network/interfaces` | `/etc/network/interfaces` |
| Firefox policies | `system/firefox/policies.json` | `/etc/firefox/policies/policies.json` |
| Yazi APT source | `system/apt/sources/yazi.list` | `/etc/apt/sources.list.d/yazi.list` |

The Yazi signing key is installed separately by
`scripts/install/setup-yazi-repository.sh`.

## User commands

Session helpers live in `scripts/session/` and are exposed through
`~/.local/bin` by `scripts/install/deploy-user-tools.sh`.

| Purpose | Repository path | User command |
|---|---|---|
| Wallpaper | `scripts/session/wallpaper.sh` | `workstation-wallpaper` |
| Idle policy | `scripts/session/idle.sh` | `workstation-idle` |
| Screen locking | `scripts/session/lock.sh` | `workstation-lock` |
| Audio control | `scripts/session/volume.sh` | `workstation-volume` |
| Brightness control | `scripts/session/brightness.sh` | `workstation-brightness` |
| Media control | `scripts/session/media.sh` | `workstation-media` |
| Screenshots | `scripts/session/screenshot.sh` | `workstation-screenshot` |
| Session/power menu | `scripts/session/power-menu.sh` | `workstation-power-menu` |

The same deployment script creates `~/.local/bin/fd -> /usr/bin/fdfind` when
Debian's `fd-find` package is installed and an upstream-named `fd` command is
not already available.

## Desktop session

### Wallpaper

`workstation-wallpaper` loads `assets/wallpapers/default.jpg` with Feh. If the
asset is unavailable, it falls back to Graphite Blue `#111318`. `~/.fehbg` is
not used.

### Locking and idle policy

Manual lock: `Super + L`.

Automatic policy:

- 10 minutes idle: lock the session;
- 15 minutes idle: power displays off;
- suspend: lock before sleep through `xss-lock --transfer-sleep-lock`.

### Desktop OSD

Volume, microphone and brightness changes use Dunst stack-tag notifications so
repeated key presses update a single OSD. Audio is controlled through `wpctl`,
brightness through `brightnessctl`, and media keys through Playerctl/MPRIS.

### Screenshots

`workstation-screenshot` supports `area`, `window` and `screen` modes. Successful
captures are saved under `~/Pictures/Screenshots`, copied to the X11 clipboard
as PNG and reported through Dunst.

### Power menu

`workstation-power-menu` exposes lock, suspend, logout, reboot and power-off
through Rofi. Destructive actions require confirmation. Suspend relies on the
existing xss-lock/systemd-logind integration.

## Desktop infrastructure

### NetworkManager

NetworkManager owns physical network interfaces. `/etc/network/interfaces`
contains only loopback configuration. Connection profiles and credentials under
`/etc/NetworkManager/system-connections/` are never tracked.

### Audio

The Debian `pipewire-audio` stack provides PipeWire, `pipewire-pulse`, ALSA
integration, WirePlumber and Bluetooth audio support. No custom PipeWire or
WirePlumber configuration is required by the portable base.

### Bluetooth and Polkit

BlueZ provides the Bluetooth stack and Blueman provides the tray/device UI.
`mate-polkit` supplies graphical authentication dialogs needed outside a full
desktop environment.

## Shell

Fish is the default interactive shell. Configuration is split into `config.fish`,
`conf.d/` fragments and reusable functions.

Notable workstation behaviour:

- `cd` delegates to Fish's builtin and then lists the destination using `eza`;
- `y` launches Yazi, follows its final CWD and then lists the resulting directory;
- `ffcd`, `ffe` and `ffec` provide FZF-based navigation/edit/search workflows;
- Zoxide provides history-based directory navigation;
- native `fzf --fish` integration provides history/file/directory selection;
- Starship owns the prompt and has no right-side prompt or command-duration field.

Fastfetch is invoked through the `hello` function and used by `fish_greeting`.
Its image logo is intended for Kitty and may be replaced without changing the
rest of the configuration.

## Neovim

Neovim is the default terminal editor. The base configuration uses built-in
Neovim functionality only and is split into options, keymaps, autocommands and
a native Graphite Blue colorscheme. `xclip` provides X11 clipboard integration.
Project-specific formatting is expected to come from EditorConfig when present.

## Yazi

Yazi is installed from its official stable APT repository and is the primary
terminal file manager. Preview support is provided by Kitty graphics, FFmpeg,
Poppler, 7-Zip, jq, resvg and ImageMagick. The Fish `y` wrapper synchronizes the
final Yazi directory back to the shell.

## Firefox

Firefox ESR is installed from Debian Stable and used as the default browser.
System-wide reproducible preferences live in `system/firefox/policies.json`.
The policy disables telemetry/studies, sponsored/recommendation content and
built-in generative-AI features by default without attempting to version the
Firefox profile.

`~/.mozilla/firefox/` remains private user state.

## GUI appearance

GTK uses Adwaita/Adwaita-dark with Graphite Blue overrides, Ubuntu Bold UI text
and Adwaita icons/cursors. Qt 5 and Qt 6 use their GTK platform-theme plugins
through `QT_QPA_PLATFORMTHEME=gtk3` set in `~/.xsessionrc`.

`scripts/configure/appearance.sh` applies matching GSettings values.

## Git

Reproducible Git behaviour lives in `~/.config/git/config`. Personal name,
email and optional signing-key ID live in `~/.gitconfig.local`, which is never
tracked. The base policy includes `main` as the default branch, Neovim as the
editor, fast-forward-only pulls, automatic upstream setup, remote pruning,
histogram diffs, `zdiff3` conflict markers and rerere.

## SSH

`~/.ssh/config` is managed, while private keys and `known_hosts` are not. Debian
Xsession owns the session-wide SSH agent; Fish does not start one. GitHub uses
`~/.ssh/id_ed25519` explicitly with `IdentitiesOnly yes`.

## GnuPG

`gpg-agent.conf` configures the graphical GTK pinentry and passphrase cache.
Actual key material and trust databases remain private user state. Git signing
is enabled only in machine-local Git configuration after a signing key exists.
