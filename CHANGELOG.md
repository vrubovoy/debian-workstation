# Changelog

All notable changes to this project are documented in this file. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions
follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-10-14

### Added

- Installer that sets up Debian 13 in one run: APT sources, packages,
  optional pinned upstream releases, system files, services and dotfiles,
  plus optional personal setup.
- X11 and i3 desktop with LightDM, i3bar and i3status, Rofi, Dunst, Picom,
  screen locking, suspend after 15 minutes idle, screenshots, a power menu and
  CopyQ clipboard history.
- Graphite Blue theme for i3, LightDM, GTK 2/3/4, Qt, Kitty, Rofi, Dunst, Fish,
  Starship, Neovim, Yazi, Fastfetch and VSCodium.
- NetworkManager, PipeWire, Bluetooth and Polkit, with on-screen displays for
  the volume, brightness and keyboard layout.
- Fish and Starship with fzf, zoxide and Yazi helpers.
- Neovim with a file explorer, fuzzy finder, Git signs, completion and
  language servers for C/C++, TypeScript, Python, Bash and Lua through Mason,
  on the optional upstream release.
- Firefox ESR configured through enterprise policies, with a default zoom of
  120%.
- Optional proprietary NVIDIA driver with suspend support.
- Git, SSH and GnuPG configuration that keeps identities and keys out of the
  repository.
- libinput settings for touchpads and mice.
- CI checks for scripts, configuration syntax and package lists, and GitHub
  releases from version tags.

[Unreleased]: https://github.com/vrubovoy/debian-workstation/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/vrubovoy/debian-workstation/releases/tag/v1.0.0
