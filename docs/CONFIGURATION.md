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

Small desktop operations that do not belong directly to an application
configuration are implemented as standalone scripts.

| Purpose | Repository path | User command |
|---|---|---|
| Wallpaper | `scripts/session/wallpaper.sh` | `~/.local/bin/workstation-wallpaper` |

### Wallpaper

The default wallpaper is stored at:

`assets/wallpapers/default.jpg`

At session startup, `workstation-wallpaper` applies it using Feh.

If the asset is unavailable, the script falls back to the Graphite Blue base
color `#111318`.

Feh is invoked with `--no-fehbg`; therefore `~/.fehbg` is intentionally not
used or managed.