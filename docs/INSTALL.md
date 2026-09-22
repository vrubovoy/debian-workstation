# Installation

> **Status: integration testing.**
>
> The automated installer is implemented and intended for Debian 13, but the
> complete clean-VM installation milestone has not yet been completed.

## Target base system

Start from a minimal Debian 13 installation with standard system utilities and
without a full desktop environment.

The installer must be run as the normal workstation user with working `sudo`
access. Do not run the complete installer as root because user dotfiles and
private identity state belong to the normal user account.

## Bootstrap

Before cloning the repository, install the small set of tools needed to obtain
and start the workstation installer:

    sudo apt update
    sudo apt install git ca-certificates curl stow

Clone the repository and enter it:

    git clone https://github.com/vrubovoy/debian-workstation.git
    cd debian-workstation

## Main installation

Run:

    ./install.sh

The installer performs the following stages:

1. Verifies that it is running as a normal user on Debian 13.
2. Installs the managed Debian 13 APT source definition with `main`, `contrib`,
   `non-free` and `non-free-firmware`, then configures the official Yazi APT
   repository.
3. Installs the Debian package manifests and Yazi.
4. Installs pinned Onefetch and VSCodium releases.
5. Deploys repository-managed system configuration under `/etc` and
   `/usr/share`.
6. Enables NetworkManager, Bluetooth and LightDM for the next boot.
7. Deploys user dotfiles with GNU Stow and `--no-folding`.
8. Exposes workstation session helpers through `~/.local/bin`.
9. Configures XDG defaults and Fish as the login shell.
10. Applies the Graphite Blue GTK/GSettings preferences.
11. Offers interactive machine-local Git, SSH and optional GPG setup.
12. Offers interactive VSCodium extension installation.

The installer intentionally does not run a full system upgrade. Package-list
refresh and workstation package installation are handled automatically, while
base-system upgrade policy remains an explicit maintenance decision.

## Graphical post-login phase

CopyQ configuration and Firefox extension setup require a running X11 session.

When the main installer is run from a TTY, log into the newly installed i3
session and run:

    ./install.sh --post-login

The post-login phase:

- reapplies desktop appearance settings in the real user session;
- configures CopyQ clipboard history;
- offers the optional Firefox extensions one by one.

If the main installer is already running from an X11 session, it offers to run
this phase immediately.

## Personal identity

The installer preserves the separation between reproducible configuration and
private user state.

It can interactively create/configure:

- `~/.gitconfig.local` for Git name, email and optional GPG signing settings;
- `~/.ssh/id_ed25519` for the workstation SSH identity;
- a GnuPG secret key when Git signing is requested and no key exists.

These files and keys are never stored in the workstation repository.

## Existing system files

The system deployment helper backs up selected mutable base-system files before
replacing them for the first time:

    /etc/apt/sources.list.d/debian.sources.debian-workstation.bak
    /etc/network/interfaces.debian-workstation.bak
    /etc/default/keyboard.debian-workstation.bak

A backup is created only once; repeated installer runs do not create backup
chains.

## Idempotency

The installer is designed to be safely re-run after repository updates.

APT installation, system file deployment, Stow deployment and user helper
links are repeatable. Machine-local identity helpers preserve existing Git and
SSH state instead of regenerating it automatically.

Interactive extension setup remains user-controlled.

## Reboot / logout

After the initial installation, reboot or fully log out and back in so the
following changes take effect consistently:

- LightDM configuration;
- X11/libinput configuration;
- keyboard configuration;
- Fish login shell;
- newly enabled desktop services.

## Validation milestone

A reproducible `v1.0` requires a successful installation from a clean Debian 13
VM after real-machine integration testing has passed. Until then, visual values
such as gaps, font sizes and widget dimensions remain polish rather than
installation blockers.
