---
title: Debian Workstation
subtitle: User guide
lang: en
---

Debian Workstation turns a fresh Debian 13 into a fast, quiet desktop: the i3
window manager on X11, one dark theme and one font, set up by a single script.
This guide takes you from an empty disk to everyday use.

# Before you start

You need:

- an amd64 computer (a laptop, a desktop or a virtual machine);
- the Debian 13 *netinst* image on a USB stick;
- a network connection during the installation.

# 1. Install Debian

Install Debian as usual, with two choices that matter:

- **Software selection:** leave only *standard system utilities* checked. No
  desktop environment: the workstation brings its own.
- **Root password:** leave it empty. Your user then gets `sudo` right away.

If you did set a root password, give your user `sudo` before going on, then log
out and back in:

```bash
su -
apt install sudo
usermod -aG sudo YOUR_USER
```

# 2. Run the installer

Log in on the text console as your user and run:

```bash
sudo apt install git
git clone https://github.com/vrubovoy/debian-workstation.git
cd debian-workstation
./install.sh
```

Keep the `debian-workstation` folder where it is: your settings are linked to
it.

The installer asks for your password, then works on its own for a while. At the
end it asks a few questions. Press **Enter** to take the suggested answer:

| Question | What it means |
|---|---|
| Git name and email | Your name on commits. Skip it if you do not use Git. |
| Sign commits with GPG | Optional; most people answer no. |
| SSH key | A key for GitHub and servers. |
| NVIDIA driver | Asked only with an NVIDIA card. |
| Yazi, Neovim, VSCodium, … | Extra programs from their developers. Yazi and Neovim are recommended. |
| Firefox and VSCodium extensions | Pick what you want, one by one. |
| Reboot now | Yes, to start the desktop. |

You can run `./install.sh` again at any time: it skips what is already done.

# 3. First login

After the reboot a login screen appears. Type your password and press
**Enter**.

- **Wi-Fi:** click the network icon at the bottom right, or run `nmtui` in a
  terminal.
- **Keyboard layout:** `Alt+Space` switches between English and Russian.
- **Everything else** is started with the keys below. `Super` is the Windows
  key.

# 4. Everyday keys

| Keys | Action |
|---|---|
| `Super+Enter` | Terminal |
| `Super+Space` | Find and start an application |
| `Super+W` / `Super+E` / `Super+C` | Firefox / file manager / VSCodium |
| `Super+Q` | Close the window |
| `Super+F` | Fullscreen |
| `Super+1` … `Super+0` | Go to workspace 1–10 |
| `Super+Alt+1` … `Super+Alt+0` | Move the window to a workspace |
| `Super+Arrows` | Move between windows |
| `Super+Ctrl+Arrows` | Move the window |
| `Super+T` | Let the window float or tile again |
| `Super+V` | Clipboard history |
| `Print` / `Shift+Print` | Screenshot of the screen / of an area |
| `Super+L` | Lock the screen |
| `Super+Backspace` | Power off, reboot, suspend, lock or log out |

Volume and brightness keys work as labelled. Without them, use `Super+F11` /
`Super+F12` for volume, `Super+F10` to mute and `Super+F1` / `Super+F2` for
brightness.

Windows open side by side and fill the screen. Use workspaces instead of
minimizing: one for the browser, one for work, one for chat.

# 5. Terminal and files

The terminal runs the Fish shell. A few shortcuts save a lot of typing:

| Command | What it does |
|---|---|
| `y` | Open the Yazi file manager; `q` quits into the folder you were in |
| `z NAME` | Jump to a folder you have visited before |
| `ffe` | Find a file by name and open it |
| `ffec TEXT` | Find text in files and open the match |
| `hello` | Show the system summary |

In the terminal `Ctrl+C` copies selected text and `Ctrl+V` pastes at the
prompt. Screenshots are saved to
`~/Pictures/Screenshots` and copied to the clipboard as well.

# 6. Sleep and power

- After 10 minutes without input the screen locks.
- After 15 minutes the screen turns off and the computer goes to sleep. While
  music or a video is playing, it stays awake and unlocked.
- Move the mouse or press a key to wake it, then type your password.

# 7. Keeping it up to date

Debian updates come as usual:

```bash
sudo apt update
sudo apt full-upgrade
```

To get a newer version of the workstation:

```bash
cd ~/debian-workstation
git pull
./install.sh
```

The same command also updates the extra programs you chose.

# 8. If something goes wrong

- **No network after the first reboot:** connect again with the network icon
  or `nmtui`. The Wi-Fi set up during the Debian installation is not kept.
- **A setting looks wrong:** run `./install.sh` again. Files it replaced are
  kept next to the new ones with the `.debian-workstation.bak` ending.
- **Anything else:** see `docs/TROUBLESHOOTING.md` in the repository, or open
  an issue on GitHub.
