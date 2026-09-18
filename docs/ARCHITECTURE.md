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
