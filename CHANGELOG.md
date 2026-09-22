# Changelog

All notable changes to this project are documented in this file. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions
follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Installer that sets up Debian 13 in one run: APT sources, packages,
  optional pinned upstream releases, system files, services and dotfiles,
  plus optional personal setup.
- X11 and i3 desktop with LightDM, i3bar and i3status, Rofi, Dunst, Picom,
  screen locking and idle policy, screenshots, a power menu and CopyQ
  clipboard history.
- Graphite Blue theme for i3, LightDM, GTK 2/3/4, Qt, Kitty, Rofi, Dunst, Fish,
  Starship, Neovim, Yazi, Fastfetch and VSCodium.
- NetworkManager, PipeWire, Bluetooth and Polkit, with on-screen displays for
  the volume and brightness keys.
- Fish and Starship with fzf, zoxide and Yazi helpers; Neovim with no plugins.
- Firefox ESR configured through enterprise policies.
- Git, SSH and GnuPG configuration that keeps identities and keys out of the
  repository.
- libinput settings for touchpads and mice.
- CI checks for scripts, configuration syntax and package lists.

[Unreleased]: https://github.com/vrubovoy/debian-workstation/commits/main
