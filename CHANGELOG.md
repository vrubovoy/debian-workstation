# Changelog

All notable changes to this project are documented in this file. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions
follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-10-14

The first release: a Debian 13 desktop on X11 and i3, installed by one script.

### Added

- **Installer.** One run sets up the APT sources, packages, system files,
  services and dotfiles. Personal setup is optional and skipped once done: Git
  identity and signing, an SSH key, the NVIDIA driver, pinned Yazi and Neovim,
  the latest VSCodium, Onefetch, AmneziaVPN, ONLYOFFICE and Telegram, and
  Firefox and VSCodium extensions.
- **Desktop.** i3 with i3bar and i3status, LightDM, the Rofi launcher and power
  menu, Dunst, Picom, screenshots and CopyQ clipboard history.
- **Power.** The screen locks after 10 minutes; after 15 the displays turn off
  and the system suspends unless sound is playing. NVIDIA cards keep their
  video memory across suspend.
- **Hardware.** NetworkManager, PipeWire, Bluetooth and Polkit; on-screen
  displays for the volume, the brightness (backlight or DDC/CI) and the
  keyboard layout; libinput settings for touchpads and mice.
- **Theme.** Graphite Blue for i3, LightDM, GTK 2/3/4, Qt, Kitty, Rofi, Dunst,
  Fish, Starship, Neovim, Yazi, Fastfetch and VSCodium, with Maple Mono NR NF
  Bold as the one font, also on web pages in Firefox.
- **Terminal.** Kitty and Fish with Starship, fzf, zoxide and Yazi helpers.
- **Neovim.** A file explorer, fuzzy finder, Git signs, completion, tree-sitter
  highlighting and language servers for C/C++, TypeScript, Python, Bash and
  Lua through Mason, on the optional upstream release.
- **Firefox ESR.** Enterprise policies without telemetry, sponsored content or
  AI features, DNS over HTTPS, an empty new tab and a default zoom of 120%.
- **Git, SSH and GnuPG.** Shared settings; identities and keys stay out of the
  repository.
- **Guide.** A short user guide in English and Russian, as PDF on every
  release.
- **CI.** Checks for scripts, configuration syntax and package lists, and
  GitHub releases from version tags.

[Unreleased]: https://github.com/vrubovoy/debian-workstation/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/vrubovoy/debian-workstation/releases/tag/v1.0.0
