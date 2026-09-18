# Architecture

Base system: Debian 13 Stable  
Display server: X11  
Window manager: i3  
Terminal: Kitty  
Launcher: Rofi  
Notifications: Dunst  
Compositor: Picom  
Status bar: i3bar + i3status  
Shell: Fish  
Prompt: Starship  
Login manager: LightDM  
Network: NetworkManager  
Audio: PipeWire + WirePlumber  
Dotfiles management: GNU Stow  
Automation: Bash  
Package manager: APT  

Fonts:
- UI: Ubuntu Bold
- Monospace: Ubuntu Mono Bold

Principles:
- No Flatpak.
- No Snap.
- No desktop environments.
- No rolling-release components for the desktop.
- Old configs are references only.
- Every persistent configuration change must be represented in this repository.

## Desktop stack

| Component | Implementation | Purpose |
|---|---|---|
| Display server | X11 / Xorg | Graphical display server |
| Display manager | LightDM | Graphical login |
| Window manager | i3 | Window and workspace management |
| Status bar | i3bar + i3status | Workspaces and system status |
| Terminal | Kitty | Terminal emulator |
| Launcher | Rofi | Application launcher |
| Notifications | Dunst | Desktop notification daemon |
| Compositor | Picom | Shadows, fading and visual effects |
| Wallpaper | Feh | Desktop background |
| Screen locker | i3lock | Session locking |
| Lock coordinator | xss-lock | Automatic lock integration |

## Desktop infrastructure

| Component | Implementation | Purpose |
|---|---|---|
| Networking | NetworkManager | Wired/Wi-Fi network management |
| Network UI | nm-applet | i3bar tray network control |
| Audio server | PipeWire | Audio routing and processing |
| Audio session manager | WirePlumber | PipeWire device/session policy |
| Audio control | Pavucontrol | Graphical audio routing/control |
| Bluetooth stack | BlueZ | Bluetooth daemon and protocol stack |
| Bluetooth UI | Blueman | Tray applet and device management |
| Authorization | Polkit + mate-polkit | Graphical privilege authentication |
| Brightness control | brightnessctl | Hardware backlight control |
| Media control | playerctl | MPRIS media control |

## Userland

| Component | Implementation | Purpose |
|---|---|---|
| Terminal editor | Neovim | General-purpose terminal text editing |
| Terminal file manager | Yazi | Keyboard-driven file management |
| Graphical file manager | Thunar | GUI file and removable-media management |
| Archive manager | Xarchiver | Graphical archive integration for Thunar |
| Browser | Firefox ESR | Web browsing |
| CLI listing | eza | Human-friendly directory listing |
| Interactive filtering | fzf | Fuzzy selection for shell workflows |
| File preview | bat | Syntax-highlighted text viewing |
| Disk overview | duf | Human-friendly filesystem usage |
| Search | ripgrep + fd | Fast content and filesystem search |
| Terminal editor | Neovim | General-purpose terminal text editing |
| Interactive shell | Fish | Interactive command-line environment |
| Prompt | Starship | Minimal directory/Git shell prompt |
| System fetch | Fastfetch | Visual system-information summary |
| Repository fetch | Onefetch | Git repository information and statistics |
| Terminal file manager | Yazi | Keyboard-first file management and previews |
| Directory history | Zoxide | Fuzzy historical directory navigation |
| Web browser | Firefox ESR | Primary web browser |
| GTK theme | Adwaita + Graphite Blue overrides | Common GTK visual layer |
| Icon theme | Adwaita | System application and action icons |
| Qt integration | Qt GTK platform theme | GTK-consistent Qt5/Qt6 appearance |
| Desktop settings | GSettings | Desktop-wide color/font/icon preferences |
| Screenshots | maim + slop | X11 screenshot capture and region selection |
| X11 window discovery | xdotool | Focused-window queries for desktop helpers |
| Session menu | Rofi + systemd | Session and power controls |
| Version control | Git | Source-control client |
| Git TUI | Lazygit | Interactive Git workflow |
| Secure remote access | OpenSSH | SSH authentication and Git transport |
| SSH key agent | Debian Xsession / ssh-agent | Session-wide private-key agent |
| Signing | GnuPG | Optional Git commit/tag signing |
| Passphrase UI | pinentry-gtk2 | Graphical GPG passphrase entry |

### Session security

Screen locking is intentionally split into two components:

- `i3lock` provides the actual authentication screen.
- `xss-lock` coordinates idle events and system sleep.

The window manager does not directly implement suspend locking.

### Session helpers

Desktop operations which require logic beyond a single application command are
implemented as small standalone scripts under `scripts/session/`.

The window manager only invokes these helpers and does not contain their
implementation details.

### Hardware controls

Hardware and media key bindings do not contain implementation logic directly in
the i3 configuration.

i3 calls stable `workstation-*` helper commands which provide the actual
implementation and optional desktop OSD.

This keeps the window-manager configuration declarative and allows the
underlying implementation to change independently.

### Terminal editor

Neovim is deliberately kept independent of external plugins in the base
workstation.

The base configuration provides editing behaviour, key mappings and the native
Graphite Blue colorscheme.

IDE-like functionality belongs to dedicated development tooling and is not a
requirement for editing or maintaining the operating system.

### GUI appearance

GTK is the canonical desktop appearance source.

GTK 3 uses Debian's Adwaita-dark theme with a minimal Graphite Blue user
stylesheet.

GTK 4 uses Adwaita with Graphite Blue semantic-color overrides.

Qt 5 and Qt 6 applications use their respective GTK 3 platform-theme plugins
through:

`QT_QPA_PLATFORMTHEME=gtk3`

This prevents GTK and Qt from developing independent visual configurations and
avoids additional theme engines such as Kvantum.

### Desktop actions

Window-manager bindings invoke stable `workstation-*` commands rather than
embedding implementation logic into the i3 configuration.

This keeps desktop actions independently testable and replaceable.

### Secrets and identity

The workstation repository contains reproducible configuration but never
cryptographic secrets or personal credentials.

The following remain machine/user state:

- SSH private keys;
- GPG private keys;
- Git name/email/signing key;
- known-host databases;
- authentication tokens.
