# Troubleshooting

Problems met while installing and running the workstation, with fixes. New
entries are added as they come up.

## The installer stops at "… is in the way and ….debian-workstation.bak already exists"

A configuration file had been replaced before and a backup from that time
already exists. Compare the two, keep what you need, remove one of them and run
the installer again.

## A configuration file in `$HOME` is not a symlink

Check whether the parent directory is itself a symlink into the repository:

```bash
ls -ld ~/.config/i3
```

That is Stow's directory folding from a run without `--no-folding`. Running
`./install.sh` again unfolds it: the installer always restows with
`--no-folding`.

## No network after the first reboot

`/etc/network/interfaces` now leaves physical interfaces to NetworkManager, so a
Wi-Fi connection configured during the Debian installation is gone. Connect
again from the network icon in the bar or with `nmtui`.

## `workstation-…: Permission denied`

The script lost its executable bit, for example after copying the repository
without Git. Restore it with:

```bash
chmod +x scripts/session/*.sh
```
