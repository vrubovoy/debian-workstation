# Configuration

How the repository maps onto the system, the choices behind it, and how to
change it.

## Where files go

| In the repository | On the system | How |
|---|---|---|
| `dotfiles/<program>/…` | `$HOME/…` | GNU Stow symlinks |
| `system/…` | `/…` | copied as root |
| `scripts/session/<name>.sh` | `~/.local/bin/workstation-<name>` | symlink |
| `packages/{base,desktop,applications,development}.txt` | installed | APT |
| `packages/nvidia.txt` | offered with an NVIDIA GPU | APT |
| `packages/external.txt` | offered one by one | pinned or latest release from GitHub |

For example, `dotfiles/i3/.config/i3/config` becomes `~/.config/i3/config`,
and `system/etc/lightdm/lightdm-gtk-greeter.conf` becomes
`/etc/lightdm/lightdm-gtk-greeter.conf`.

### Dotfiles

Each directory under `dotfiles/` is a Stow package, linked with
`--no-folding`: every file is its own symlink into the repository and every
directory stays a real directory. That keeps `~/.ssh` and `~/.gnupg` real
directories, so keys created in them can never end up in the repository.

Editing a file in the repository changes the live configuration at once;
reload the program to see it (`Super+Ctrl+R` for i3). A file that is already in
the way when the installer runs is moved to `*.debian-workstation.bak`.

### System files

Files under `system/` are copied, not linked, because they belong to root.
After changing one, run `./install.sh` (or `sudo scripts/install/system.sh`).
The first time the installer replaces a file, it keeps the system's version as
`*.debian-workstation.bak` and records the path in
`/etc/debian-workstation/managed-files`; later runs overwrite it without new
backups.

- `/etc/apt/sources.list.d/debian.sources`: Debian 13 with contrib, non-free
  and non-free-firmware. Debian entries in an old one-line
  `/etc/apt/sources.list` are commented out (after a backup); other entries
  there are left alone.
- `/etc/network/interfaces`: loopback only; NetworkManager owns everything else.
- `/etc/default/keyboard`: US/RU layouts, `Alt+Space` to switch and Compose on
  Right Alt, for the console, LightDM and X alike.
- `/etc/X11/xorg.conf.d/90-workstation-input.conf`: tap to click and natural
  scrolling on touchpads, slightly slower adaptive acceleration for mice.
- `/etc/X11/xorg.conf.d/20-workstation-nvidia.conf`: RGB output with the
  NVIDIA driver on HDMI monitors that also offer YCbCr 4:2:0.
- `/etc/udev/rules.d/90-workstation-wakeup.rules`: the graphics card's PCIe
  port does not wake the system.
- `/etc/firefox-esr/policies/policies.json`: generated from the repository
  file plus the extensions chosen on this machine (see below).
- `/usr/lib/firefox-esr/workstation.cfg` with `defaults/pref/autoconfig.js`:
  Firefox's AutoConfig, which applies `workstation-newtab.css` next to it to
  every profile, sets Maple Mono for web pages and the default zoom to 120% in
  profiles that have none yet (a zoom chosen in *Settings* stays).
- `/usr/local/share/fonts/maple-mono/`: the font, system-wide so that LightDM
  has it too. `~/.config/fontconfig/conf.d/99-maple-mono.conf` makes it every
  generic family and its Bold the plain weight.
- `/etc/modprobe.d/workstation-nvidia.conf`: the NVIDIA driver keeps the
  video memory across suspend.
- `/etc/default/grub.d/workstation.cfg`: the GRUB menu over the wallpaper.
  The installer writes the image to `/boot/grub/workstation.jpg` (GRUB reads
  only baseline JPEGs) and runs `update-grub`.
- `/usr/share/locale/en/LC_MESSAGES/lightdm-gtk-greeter.mo`: turns the login
  form's hints into `login` and `password`. It applies with an English system
  locale; other languages keep the greeter's own translation.

### Commands

| Command | Does |
|---|---|
| `workstation-lock` | Lock the screen (i3lock over the wallpaper) |
| `workstation-power-menu` | Tiles for power off, reboot, suspend, lock and log out; the first, second and last confirm with a 5-second countdown |
| `workstation-screenshot area\|window\|screen` | Save to `~/Pictures/Screenshots` and copy to the clipboard |
| `workstation-clipboard` | Pick from the clipboard history (`start`: start CopyQ) |
| `workstation-volume up\|down\|mute\|mic-mute` | Volume with an on-screen display |
| `workstation-brightness up\|down` | Laptop backlight, or the monitors over DDC/CI on a desktop, with an on-screen display |
| `workstation-layout` | Show the current keyboard layout on screen |
| `workstation-idle` | Suspend after 15 minutes without input, unless sound is playing; not in a virtual machine (i3 starts it) |
| `workstation-wallpaper` | Set the wallpaper |

`~/.xsessionrc` puts `~/.local/bin` on the session `PATH`, so i3 calls them by
name, and keeps Python bytecode in `~/.cache/python`, which makes Kitty start
twice as fast. Debian names the `fd` and `bat` commands `fdfind` and
`batcat`, so the installer adds `~/.local/bin/fd` and `~/.local/bin/bat` too.

## Design

- **Debian stable first.** Everything else is optional and offered one by one
  by `scripts/configure/external-packages.sh`. Yazi and Neovim are pinned to a
  version, because their configuration depends on it; VSCodium, Onefetch,
  AmneziaVPN, ONLYOFFICE and Telegram follow their latest GitHub releases.
  Each download is checked against its SHA-256 and refused if it does not
  match; installed ones are updated on the next run. AmneziaVPN has no
  `.deb`; its own installer runs headless into `/opt/AmneziaVPN`. Neovim and
  Telegram are release archives unpacked into `/opt`; Telegram adds itself to
  the launcher the first time it is started with `Telegram`.
- **One theme source.** GTK 3 is Adwaita-dark and GTK 4 is Adwaita, each with a
  Graphite Blue `gtk.css`. Qt 5 and 6 follow GTK through
  `QT_QPA_PLATFORMTHEME=gtk3`, and the same values are set as GSettings. One
  font serves everything: Maple Mono NR NF in Bold, which also carries the Nerd
  Font icons.
- **Firefox through policies**, not a profile `user.js`. The policies turn off
  telemetry, studies, sponsored content, online Firefox Suggest and the AI
  features, and turn on DNS over HTTPS (Cloudflare, falling back to system
  DNS). The dark theme is the default, and with Firefox Home emptied (no
  shortcuts, stories, weather or widgets) the search field sits in the middle
  of a new tab. Optional extensions are
  picked with `scripts/configure/firefox-extensions.sh`; the choice is kept in
  `/etc/debian-workstation/firefox-extensions` and Firefox installs them on
  its next start.
- **NVIDIA.** On a machine with an NVIDIA GPU, `scripts/configure/nvidia.sh`
  offers the proprietary driver instead of nouveau. Its `nvidia-suspend` and
  `nvidia-resume` services save and restore the video memory around suspend.
  Next to integrated graphics the answer defaults to no: there nouveau can
  power an idle NVIDIA card off, which the proprietary driver cannot do for
  cards older than Turing.
- **Locking.** `workstation-lock` is the only locker. It shows the wallpaper,
  fitted to each monitor once and cached in `~/.cache/workstation`. `xss-lock`
  runs it after 10 minutes idle and before suspend. After 15 minutes the
  displays turn off and `workstation-idle` suspends the system, unless sound is
  playing.
- **Focus.** The focused window, the Rofi menus and the focused LightDM field
  share the look of a focused text field: an accent border and a faint ring
  around it. For windows the ring is picom's shadow, drawn only around the
  focused one.
- **Launcher.** Rofi would show applications whose icon is missing with a
  blank icon, so the installer hides them for the user with `Hidden=true`
  entries in `~/.local/share/applications`. Run `./install.sh` again after
  installing new software.
- **Clipboard.** CopyQ keeps the last 200 clipboard items but ignores the
  mouse selection (PRIMARY). `workstation-clipboard start` applies these
  settings at every login, so they always match the repository.
- **No secrets in Git.** Name, email and signing key live in
  `~/.gitconfig.local`; SSH and GPG keys, `known_hosts` and browser profiles
  stay on the machine. `scripts/configure/` creates them locally.

## Neovim

Debian 13 ships Neovim 0.10; the plugins need 0.11 or later, so the upstream
release is offered with the other upstream releases (unpacked into `/opt/nvim`,
linked as `/usr/local/bin/nvim`). Without it Neovim starts with the built-in
features only.

The plugins are managed by lazy.nvim and pinned in
`dotfiles/nvim/.config/nvim/lazy-lock.json`; the installer downloads them in
advance. `:Lazy update` moves them forward and rewrites that file in the
repository.

| Plugin | Keys |
|---|---|
| nvim-tree: file explorer | `Space e` |
| fzf-lua: files, text, buffers, recent files, help | `Space f f/g/b/r/h` |
| gitsigns: changed lines | `]h` / `[h`, `Space h p/s/r/b` preview / stage / reset / blame |
| blink.cmp: completion | `Tab` accepts |
| Mason + nvim-lspconfig: language servers | `gd`, `gD`, `Space c f` format, and Neovim's own `K`, `grn`, `gra`, `grr`, `gri`, `gO`, `[d` / `]d` |

These language servers start by file type in every project:

| Languages | Server |
|---|---|
| C, C++ | clangd |
| JavaScript, TypeScript, React | ts_ls; tsc from the project with TypeScript 7 |
| Python | basedpyright |
| Bash | bashls |
| Lua | lua_ls |

A server that is not on `PATH` is installed through Mason the first time a
file of its type is opened (clangd comes from Debian; Node.js, npm and
python3-venv cover the others). Neovim's own parsers highlight C, Lua, Vim
script, Markdown and help files with tree-sitter.

A project can add other servers or settings in `.nvim.lua` at its root, using
the names from `:help lspconfig-all`:

```lua
vim.lsp.config("clangd", { cmd = { "clangd", "--background-index" } })

require("workstation.lsp").enable({ "rust_analyzer" })
```

Neovim reads `.nvim.lua` from the current directory and the ones above it,
and asks once whether to trust a new or changed file.

## Common changes

- **Package:** add the name to the matching `packages/*.txt` and run
  `./install.sh`. CI checks that every name resolves on Debian 13.
- **Configuration file:** put it under `dotfiles/<program>/` at its path
  relative to `$HOME` and run `./install.sh`; a new directory becomes a new
  Stow package automatically.
- **System file:** put it under `system/` at its absolute path.
- **New file:** start it with the header of a file of the same type (`@file`,
  `@author`, `@brief`, and `@path` / `@apply` for configuration files).
- **Command:** add an executable `scripts/session/<name>.sh`; after
  `./install.sh` it is available as `workstation-<name>`.
- **Upstream release:** add a line to `packages/external.txt`; its header
  shows the URL placeholders and how to pin a version instead.
- **Font:** rebuild Maple Mono at commit `c08fda9` of
  [maple-font](https://github.com/subframe7536/maple-font) with
  `build.py --ttf-only --width narrow --feat cv01,cv02,cv05,cv08,cv31,cv33,cv34,cv35,cv36,cv37,cv38,cv41,cv44,cv61,cv64,cv66,ss03,ss05,ss06,ss09,ss10`,
  copy `fonts/NF/MapleMonoNR-NF-Bold.ttf` and `-BoldItalic.ttf` to
  `system/usr/local/share/fonts/maple-mono/` and run `./install.sh`.
- **Wallpaper:** replace `assets/wallpapers/default.jpg`, then run
  `workstation-wallpaper`, and `./install.sh` for the boot menu.
- **Firefox extension:** add its ID and addons.mozilla.org slug to
  `packages/firefox-extensions.txt`, then run
  `scripts/configure/firefox-extensions.sh`.
- **VSCodium extension:** add it to `packages/vscodium-extensions.txt` (it
  must exist on Open VSX).
- **CPU temperature in the bar:** it depends on the machine; see the end of
  `dotfiles/i3status/.config/i3status/config`.

## Checks

`.github/workflows/lint.yml` runs on every push. It checks shell scripts
(syntax, ShellCheck, executable bit); Fish, JSON, JSONC, TOML and YAML syntax;
the GitHub workflows, the Stow packages, the Rofi themes and the i3 config;
whitespace, line endings and final newlines. It also resolves every package
list in a Debian 13 container with the installer's own repository setup and
rejects packages listed twice.
