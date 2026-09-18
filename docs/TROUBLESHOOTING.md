# Troubleshooting

This document records problems reproduced while building or deploying the
workstation and their verified solutions. It will grow during real-machine and
clean-VM integration testing.

## Stow did not create a symlink for a configuration file

### Symptom

A managed file such as `~/.config/i3status/config` looks like a regular file,
or Stow appears not to create the expected per-file symlink.

### Cause

GNU Stow may use directory folding and create a link for the parent directory
instead, for example:

    ~/.config/i3status -> <repository>/dotfiles/i3status/.config/i3status

Files inside that directory then appear regular because the directory itself is
the symbolic link.

### Fix

This repository deliberately disables directory folding:

    stow --no-folding -t "$HOME" <package>

To convert an already-folded package, remove its Stow links first and redeploy:

    stow -D -t "$HOME" <package>
    stow --no-folding -t "$HOME" <package>

Never allow `~/.ssh` or `~/.gnupg` to become directory-level links into the
repository.

## `workstation-*`: permission denied

Session helpers must be executable in the repository. Check:

    find scripts -name '*.sh' -printf '%m %p\n'

Expected mode for executable scripts is `755`. The archive/repository should
preserve these executable bits.

## Yazi/Fish cannot find `fd`

Debian's `fd-find` package installs `/usr/bin/fdfind`, while upstream tools often
expect `fd`. Run:

    scripts/install/deploy-user-tools.sh

It creates `~/.local/bin/fd -> /usr/bin/fdfind` when an upstream-named `fd`
command is not already available.
