# Installation

> **Status: draft / not yet end-to-end validated.**
>
> The repository is currently intended for manual integration testing on
> Debian 13. `install.sh` intentionally does not automate installation yet.

## Target base system

Start from a minimal Debian 13 installation with standard system utilities and
without a full desktop environment.

## Current manual flow

The intended sequence is:

1. Update the base system.
2. Install bootstrap tools needed to clone and deploy the repository.
3. Clone `debian-workstation`.
4. Configure the official Yazi APT repository.
5. Install the package manifests.
6. Deploy privileged system configuration.
7. Deploy user dotfiles with GNU Stow and `--no-folding`.
8. Expose session helpers through `~/.local/bin`.
9. Apply desktop appearance settings.
10. Configure machine-local Git/SSH/GPG identity as desired.
11. Log out/reboot so Xsession and LightDM changes are applied.
12. Verify the complete desktop manually.

## Bootstrap tools

Before the repository can manage itself, install at least:

    sudo apt update
    sudo apt install git ca-certificates curl stow

## Repository deployment helpers

The repository already contains small helpers that will later be orchestrated
by the final installer:

    scripts/install/setup-yazi-repository.sh
    scripts/install/stow-dotfiles.sh
    scripts/install/deploy-user-tools.sh
    scripts/configure/appearance.sh
    scripts/configure/git-local.sh
    scripts/configure/ssh-key.sh

These helpers are still undergoing integration testing. Review them before
executing them on an existing workstation.

## Stow rule

Always deploy repository dotfiles with directory folding disabled. Either use:

    scripts/install/stow-dotfiles.sh

or, for one package:

    cd dotfiles
    stow --no-folding -t "$HOME" <package>

## Validation milestone

A reproducible `v1.0` requires a successful clean installation in a new Debian
13 VM after the real-machine integration test has passed. Until that happens,
visual values such as gaps, font sizes and widget dimensions are considered
polish rather than installation blockers.
