# Changelog

## Unreleased

### Added

- Debian 13 / X11 / i3 workstation architecture.
- Graphite Blue desktop appearance across i3, LightDM, Kitty, Rofi, Dunst,
  GTK/Qt, Neovim and Yazi.
- i3bar/i3status system status, PipeWire audio, NetworkManager, Bluetooth and
  Polkit desktop infrastructure.
- Repository-managed wallpaper, lock/idle policy, hardware/media controls,
  screenshot workflow and Rofi session/power menu.
- Fish + Starship shell environment with FZF/Zoxide helpers and preserved
  workstation navigation workflows.
- Neovim terminal editor and Yazi/Thunar file-management stack.
- Firefox ESR with reproducible system policies.
- Git, OpenSSH, Lazygit and optional GnuPG signing infrastructure with secrets
  kept outside version control.
- GNU Stow dotfile deployment with directory folding explicitly disabled.
- Repository helpers for Yazi repository setup, Stow deployment and stable
  `workstation-*` user commands.
- Added persistent X11 clipboard history using CopyQ with a Rofi frontend.
- Added VSCodium with Graphite Blue styling and interactive extension setup.
- Added interactive Firefox extension setup and migrated remaining portable browser preferences to enterprise policies.
- Added hardware-independent X11/libinput mouse and touchpad configuration.
- Finalized Fastfetch Kitty image rendering and terminal Nerd Font symbol fallback.

### Changed

- Replaced legacy CachyOS/Noctalia/Wayland-specific components with explicit
  Debian/X11 equivalents.
- Replaced independent Qt theming with GTK platform-theme integration.
- Separated reproducible Git behaviour from machine-local identity/signing data.

### Fixed

- Removed duplicate i3 `Ctrl+Alt+Delete` bindings.
- Enabled the selected Thunar `Super+E` binding.
- Removed duplicate package and Fish-abbreviation entries.
- Corrected Yazi theme TOML syntax.
