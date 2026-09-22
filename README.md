# Debian Workstation

[![Lint](https://github.com/vrubovoy/debian-workstation/actions/workflows/lint.yml/badge.svg)](https://github.com/vrubovoy/debian-workstation/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/vrubovoy/debian-workstation?sort=semver)](https://github.com/vrubovoy/debian-workstation/releases)
[![License: MIT](https://img.shields.io/github/license/vrubovoy/debian-workstation)](LICENSE)
[![Debian 13](https://img.shields.io/badge/Debian-13%20trixie-A81D33?logo=debian&logoColor=white)](https://www.debian.org/releases/trixie/)

A minimal Debian 13 desktop built on X11 and i3, with one dark theme
(Graphite Blue), installed by a single script and kept entirely in Git.

> **Status:** pre-release. The installer is being tested on a virtual machine,
> a laptop and a desktop PC before 1.0.0.

## What you get

| | |
|---|---|
| Session | Xorg, i3, i3bar + i3status, LightDM |
| Desktop | Rofi, Dunst, Picom, i3lock + xss-lock, CopyQ clipboard history |
| Terminal | Kitty, Fish + Starship, Neovim, Yazi |
| Applications | Firefox ESR, Thunar, VSCodium |
| System | NetworkManager, PipeWire, Bluetooth (BlueZ + Blueman), Polkit |
| Development | Git, Lazygit, OpenSSH, GnuPG, clangd |

Everything uses Ubuntu Bold for the interface and Ubuntu Mono Bold in the
terminal. There is no full desktop environment, Flatpak or Snap.

## Requirements

- Debian 13 from the netinst image, **without a desktop environment**: in
  *Software selection* keep only *standard system utilities*.
- A normal user that can run `sudo`. If you set a root password during the
  installation, add sudo yourself and log in again:

  ```bash
  su -
  apt install sudo
  usermod -aG sudo <user>
  ```

  With an empty root password the Debian installer sets up sudo already.
- An amd64 machine. On other architectures the pinned Onefetch and VSCodium
  releases are skipped, and nothing else has been tested.

## Installation

Log in on the TTY as your user:

```bash
sudo apt install git
git clone https://github.com/vrubovoy/debian-workstation.git
cd debian-workstation
./install.sh
```

Keep the clone where it is: your configuration files become symlinks into it.

The installer asks for your sudo password at the start (sudo may ask again
near the end if its timeout ran out during a long install) and then:

1. **As root:** sets up the Debian (with contrib and non-free) and Yazi APT
   sources, installs the packages from `packages/`, installs the pinned
   Onefetch and VSCodium releases, copies `system/` to `/`, enables
   NetworkManager, Bluetooth and LightDM, and makes Fish your login shell.
2. **As you:** links `dotfiles/` into your home directory with GNU Stow, adds
   the `workstation-*` commands to `~/.local/bin`, and sets default
   applications and GTK settings.
3. **Personal setup**, each step optional and skipped once done: Git name and
   email with optional GPG signing, an SSH key, Firefox extensions and
   VSCodium extensions.

Any file it replaces is kept once as `*.debian-workstation.bak`. It does not
upgrade the system (`apt full-upgrade` stays your call) and is safe to run again.

Reboot when it finishes and log in to i3. Physical network interfaces now
belong to NetworkManager: connect to Wi-Fi from the tray icon or with `nmtui`.

To update later:

```bash
git pull
./install.sh
```

## Keys

`Super` is the Windows key.

| Keys | Action |
|---|---|
| `Super+Enter` | Terminal |
| `Super+Space` or `Super+Ctrl+Enter` | Application launcher |
| `Super+W` / `Super+C` / `Super+E` | Firefox / VSCodium / Thunar |
| `Super+V` | Clipboard history |
| `Super+Q` | Close window |
| `Super+F` or `Alt+Enter` | Fullscreen |
| `Super+T` | Floating on/off |
| `Super+Shift+W` | Tabbed layout on/off |
| `Super+Arrows` or `Super+H/J/K` | Focus window |
| `Super+Ctrl+Arrows` or `Super+Ctrl+H/J/K/L` | Move window |
| `Super+Shift+Arrows` | Focus monitor |
| `Super+Shift+Ctrl+Arrows` | Move window to monitor |
| `Super+-` / `Super+=` | Narrower / wider (`Shift` for height) |
| `Super+1` … `Super+0` | Workspace 1–10 |
| `Super+Alt+1` … `Super+Alt+0` | Move window to workspace |
| `Super+Tab` | Previous workspace |
| `Super+Wheel` | Next / previous workspace (`Ctrl` takes the window along) |
| `Super+L` | Lock |
| `Super+Backspace` or `Ctrl+Alt+Delete` | Lock, suspend, log out, reboot, power off |
| `Print` / `Shift+Print` or `Super+P` / `Alt+Print` | Screenshot of screen / area / window |
| `Super+Shift+P` | Displays off |
| `Super+Ctrl+R` / `Super+Shift+R` | Reload / restart i3 |
| `Alt+Space` | Switch keyboard layout (US/RU) |

Volume, microphone, brightness and media keys work as labelled.

In Fish: `y` opens Yazi and follows its last directory, `z` jumps to a
visited directory, `ffcd`/`ffe` fuzzy-find a directory or file, `ffec`
searches file contents, `hello` shows the system summary. Every directory
change lists the new directory.

## Repository

```text
install.sh     the installer
packages/      APT package lists, pinned releases, optional extensions
system/        files copied to the same path under /
dotfiles/      Stow packages linked into $HOME
scripts/       installer steps, personal setup, workstation-* commands
assets/        wallpaper
docs/          configuration reference and troubleshooting
```

- [Configuration](docs/CONFIGURATION.md): what goes where, design choices and
  common changes.
- [Troubleshooting](docs/TROUBLESHOOTING.md): known problems and fixes.
- [Changelog](CHANGELOG.md)

## License

[MIT](LICENSE)
