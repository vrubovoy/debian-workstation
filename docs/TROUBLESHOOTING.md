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

## The system does not resume from suspend

Look at the kernel log of the attempt after a forced reboot:

```bash
sudo journalctl -b -1 -k | tail
```

If it ends at `PM: suspend entry (deep)`, test how far suspend gets without
cutting the power; each level resumes after 5 seconds:

```bash
for level in freezer devices platform processors core; do
    echo "$level" | sudo tee /sys/power/pm_test
    sudo systemctl suspend && sleep 15
done
echo none | sudo tee /sys/power/pm_test
```

If every level comes back, the drivers are fine and the firmware fails to
resume: update the BIOS. With an NVIDIA GPU, also check that
`/proc/driver/nvidia/params` has `PreserveVideoMemoryAllocations: 1`.

## The system wakes up right after suspend

A wakeup source fires at once. `cat /proc/acpi/wakeup` lists the enabled ones;
`echo NAME | sudo tee /proc/acpi/wakeup` toggles one until the next boot.

## The picture is green and monochrome (NVIDIA, HDMI)

The driver sends YCbCr 4:2:0. `nvidia-settings -q CurrentColorSpace` shows `3`
for 4:2:0 and `0` for RGB. `20-workstation-nvidia.conf` in
`/etc/X11/xorg.conf.d` forces RGB after a reboot.

## The NVIDIA driver does not load with Secure Boot

Enroll the DKMS signing key, reboot and choose *Enroll MOK*:

```bash
sudo apt install mokutil
sudo mokutil --import /var/lib/dkms/mok.pub
```

## `workstation-…: Permission denied`

The script lost its executable bit, for example after copying the repository
without Git. Restore it with:

```bash
chmod +x scripts/session/*.sh
```
