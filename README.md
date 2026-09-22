# Debian Workstation

Reproducible, minimal and long-lived Debian workstation based on Debian 13,
X11 and i3.

> **Status: work in progress.**
>
> The configuration is under active development and has not yet been validated
> end-to-end on a clean Debian 13 VM. The automated installer is implemented and
> is currently undergoing real-system integration testing.

## Stack

The desktop is intentionally assembled from small, replaceable components:

- X11 / Xorg + i3;
- LightDM;
- i3bar + i3status;
- Kitty;
- Fish + Starship;
- Rofi, Dunst and Picom;
- NetworkManager;
- PipeWire + WirePlumber;
- BlueZ + Blueman;
- Thunar + Yazi;
- Neovim;
- Firefox ESR;
- Git, OpenSSH and optional GnuPG signing.

The visual theme is **Graphite Blue**, with Ubuntu Bold for UI text and Ubuntu
Mono Bold for terminal/code text.

## Repository layout

```text
debian-workstation/
├── packages/      APT and external package manifests
├── dotfiles/      user configuration deployed with GNU Stow
├── system/        system configuration copied to privileged locations
├── scripts/       configuration, installation and session helpers
├── assets/        wallpapers and other static assets
└── docs/          architecture, configuration and operational documentation
```

## Design principles

- Debian Stable is the operating-system base.
- No Flatpak or Snap is required by the workstation.
- No full desktop environment is installed.
- Persistent configuration belongs in this repository.
- Private keys, credentials, browser profiles and runtime state never belong in
  the repository.
- User dotfiles are deployed with GNU Stow using `--no-folding`.
- Hardware-specific configuration is kept out of the portable base whenever
  possible.

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — design decisions and component layers.
- [Configuration](docs/CONFIGURATION.md) — managed paths and component behaviour.
- [Installation](docs/INSTALL.md) — current manual installation flow and status.
- [Maintenance](docs/MAINTENANCE.md) — keeping the workstation and repository up to date.
- [Troubleshooting](docs/TROUBLESHOOTING.md) — verified deployment problems and fixes.

## Current development stage

The immediate goal is to complete automated installation testing on the real
Debian 13 workstation, resolve functional issues, and then validate the same
installer from a clean VM. Visual dimensions such as font sizes, gaps, padding
and widget widths remain intentionally deferred until functional validation is
complete.
