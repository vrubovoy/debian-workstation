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