# Architecture

The workstation is built around Debian 13 Stable, X11 and i3. Its design
prioritizes long-term stability, explicit configuration, replaceable
components and reproducibility.

## Principles

- Debian Stable provides the operating-system base.
- X11 and i3 form a deliberately small graphical environment.
- No Flatpak or Snap is required by the base workstation.
- No full desktop environment is installed.
- Persistent configuration changes are represented in this repository.
- Old workstation configurations are references, not sources to copy blindly.
- Hardware-specific settings are excluded from the portable base when possible.
- Secrets and personal runtime state are never version-controlled.

## Desktop stack

| Component | Implementation | Purpose |
|---|---|---|
| Display server | X11 / Xorg | Graphical display server |
| Display manager | LightDM | Graphical login |
| Window manager | i3 | Window and workspace management |
| Status bar | i3bar + i3status | Workspaces and system status |
| Terminal | Kitty | Terminal emulator |
| Launcher | Rofi | Application launcher and desktop menus |
| Notifications | Dunst | Desktop notification daemon and OSD |
| Compositor | Picom | VSync, shadows, rounded corners and fading |
| Wallpaper | Feh | X11 desktop background |
| Screen locker | i3lock | Session authentication screen |
| Lock coordinator | xss-lock | Idle and systemd-logind lock integration |
| Screenshots | maim + slop | X11 screenshots and region selection |
| Clipboard history | CopyQ | Persistent X11 clipboard-history backend |
| Clipboard interface | Rofi | Searchable clipboard-history frontend |

## Desktop infrastructure

| Component | Implementation | Purpose |
|---|---|---|
| Networking | NetworkManager | Wired and Wi-Fi network management |
| Network UI | nm-applet | Tray network control |
| Audio server | PipeWire | Audio routing and processing |
| Session manager | WirePlumber | PipeWire policy and default-device management |
| Audio UI | Pavucontrol | Graphical audio routing and control |
| Bluetooth stack | BlueZ | Bluetooth services |
| Bluetooth UI | Blueman | Tray applet and device management |
| Authorization | Polkit + mate-polkit | Graphical privilege authentication |
| Brightness | brightnessctl | Hardware backlight control |
| Media control | playerctl | MPRIS media control |

## Userland

| Component | Implementation | Purpose |
|---|---|---|
| Interactive shell | Fish | Daily interactive shell |
| Prompt | Starship | Minimal directory/Git prompt |
| Terminal editor | Neovim | General-purpose terminal editing |
| Terminal file manager | Yazi | Keyboard-first file management and previews |
| Graphical file manager | Thunar | GUI file and removable-media management |
| Archive UI | Xarchiver | Graphical archive integration for Thunar |
| Browser | Firefox ESR | Primary web browser |
| Directory listing | eza | Human-friendly directory listing |
| Fuzzy filtering | fzf | Shell selection and navigation workflows |
| Text preview | bat | Syntax-highlighted file viewing |
| Disk overview | duf | Human-friendly filesystem usage |
| Search | ripgrep + fd | Fast content and filesystem search |
| Directory history | Zoxide | Fuzzy historical directory navigation |
| System summary | Fastfetch | Visual system-information summary |
| Repository summary | Onefetch | Git repository information and statistics |
| Graphical code editor | VSCodium | VS Code-compatible editor without Microsoft branding/telemetry defaults |

## Appearance

GTK is the canonical source of GUI appearance. GTK 3 uses Adwaita-dark with
Graphite Blue overrides; GTK 4 uses Adwaita with Graphite Blue semantic colors.
Qt 5 and Qt 6 use their GTK platform-theme plugins through
`QT_QPA_PLATFORMTHEME=gtk3` rather than maintaining independent Qt themes.

The base typography is Ubuntu Bold for UI text and Ubuntu Mono Bold for
terminal/code text. Adwaita is the base icon and cursor theme.

## Session security

Screen locking is split into two components:

- `i3lock` provides the authentication screen;
- `xss-lock` coordinates X11 idle events and systemd-logind sleep requests.

`xss-lock --transfer-sleep-lock` prevents suspend from completing before the
session has been secured.

## Session helpers

Desktop actions that need logic beyond a single command live under
`scripts/session/`. i3 invokes stable `workstation-*` commands instead of
embedding shell pipelines in the window-manager configuration.

This keeps desktop actions independently testable and allows implementations to
change without rewriting key bindings.

## Shell and editor

Fish is the interactive shell and Starship owns the prompt. The shell retains a
small set of deliberate workstation conveniences, including automatic `eza`
listing after `cd`, Yazi CWD synchronization, and FZF-based navigation/search
helpers.

Neovim intentionally uses only built-in functionality in the base workstation.
IDE-like development tooling is not required for operating-system maintenance.

## Version control and identity

Git, OpenSSH and GnuPG configuration is reproducible, but personal identity and
cryptographic secrets remain local machine/user state.

The repository never contains:

- SSH private keys;
- GPG private keys or trust databases;
- Git name, email or signing-key identifiers;
- authentication tokens;
- browser profiles or credentials.

The Debian X11 session owns the lifetime of the SSH agent; Fish does not spawn
per-terminal agents.

## Configuration deployment

User configuration is deployed through GNU Stow with directory folding disabled.
System configuration is copied explicitly to privileged locations. This
separation prevents mutable system/user state from being accidentally redirected
into the repository.

### Clipboard history

CopyQ provides persistent clipboard monitoring and storage.

Its native window and tray interface are not part of the normal workstation
workflow. Rofi acts as the primary clipboard-history frontend.

The regular X11 clipboard is monitored, while the X11 PRIMARY selection is
deliberately ignored so merely selecting text with the mouse does not create
history entries.

Selecting an entry in Rofi restores it to the clipboard but does not
automatically paste it into the focused application.

### VSCodium

VSCodium is the workstation's graphical code editor.

It is installed from the official VSCodium APT repository rather than from
Snap, Flatpak or manually downloaded packages.

The editor uses the built-in dark theme as a structural base, while the
Graphite Blue workstation palette is applied explicitly through user settings.

No external color-theme extension is required.

C/C++ language intelligence is provided primarily by clangd.

VSCodium uses Open VSX as its default extension registry.