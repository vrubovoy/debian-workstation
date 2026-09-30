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

## Suspend fails or the screen stays black after resume (NVIDIA)

With nouveau, Debian's default driver for NVIDIA cards, this is expected. Check
which driver is in use:

```bash
lspci -k -d 10de::0300 | grep 'driver in use'
```

If it says `nouveau`, install the proprietary driver with
`scripts/configure/nvidia.sh` and reboot. If it says `nvidia` and suspend still
fails, check that the power settings are loaded and the services are enabled:

```bash
grep PreserveVideoMemoryAllocations /proc/driver/nvidia/params
systemctl is-enabled nvidia-suspend nvidia-resume
```

The first line must end in `1`. The kernel log of the attempt is in
`sudo journalctl -b -1 -k` after a forced reboot, or `sudo journalctl -b -k`
if the system came back.

## The NVIDIA driver does not load with Secure Boot

The DKMS module is signed with a local key that the firmware does not know
yet. Enroll it, reboot and choose *Enroll MOK* in the MOK manager:

```bash
sudo apt install mokutil
sudo mokutil --import /var/lib/dkms/mok.pub
```

## Brightness keys stop working on a desktop with the NVIDIA driver

Some cards need software I²C for DDC/CI under the proprietary driver. Check
with `ddcutil detect`; if no monitor is found, add
`options nvidia-current NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100` to
`/etc/modprobe.d/workstation-nvidia.conf` and reboot.

## `workstation-…: Permission denied`

The script lost its executable bit, for example after copying the repository
without Git. Restore it with:

```bash
chmod +x scripts/session/*.sh
```
