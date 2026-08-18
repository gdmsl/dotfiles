# nomad — the portable SSD

NixOS on an external SSD: encrypted storage plus a full desktop that boots on
arbitrary x86_64 machines, and can install NixOS onto others.

Layout and the reasoning behind it are in `system/disko-nomad.nix`; boot and
hardware config in `system/nomad.nix`.

```
p1     2 GiB   ESP, FAT32                          /boot        unencrypted
p2   300 GiB   LUKS "carry"    @home / @personal    /home/gdmsl, ~/Personal
p3   158 GiB   LUKS "nomad-os" @ / @nix / @snapshots  /, /nix, /.snapshots
```

Your home is on the **data** container, not the OS one, so reinstalling the OS
doesn't touch your files.

## Booting it

Pick the disk from the machine's firmware boot menu (usually F12, F9 or Esc).

**Secure Boot has to be off.** The kernel isn't signed by a key any firmware
trusts. Some corporate machines lock this down and simply won't boot the disk —
that's a hard limit, not something to configure around.

You'll be asked for the `nomad-os` passphrase in the initrd. `carry` unlocks
after that on its own, using the keyfile on the decrypted root.

If graphics don't come up, press `e` at the GRUB menu and add `nomodeset` to the
kernel line for that boot.

## Everyday use

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nomad
nix flake update && sudo nixos-rebuild switch --flake ~/dotfiles#nomad
```

Rebuilding while booted from the SSD works but is slower than on an internal
disk. The alternative is to do it from another machine — mount the SSD and
rebuild from inside it, which uses that machine's CPU:

```bash
nomad-mount
sudo nixos-enter --root /mnt -c \
  'nixos-rebuild boot --flake /home/gdmsl/dotfiles#nomad'
nomad-umount
```

`boot` rather than `switch`, since the running system isn't the one being built —
the new generation applies at the next boot.

## Mounting it from another machine

To repair or rebuild the installation without booting it:

```bash
nomad-mount                       # unlocks and mounts everything under /mnt
sudo nixos-enter --root /mnt      # a shell inside the installed system
nomad-umount                      # unmount, close, restart udiskie
```

`nomad-mount` delegates to disko, so the mounts always match the real layout. It
stops `udiskie` first — the automatic mounts under `/run/media` use the btrfs top
level with `nosuid,nodev`, which is wrong for a chroot.

## Installing NixOS onto another machine

The running SSD is a usable installer: it has git, this repo and nix.

```bash
# partition the target however you like, mount it at /mnt, then
sudo nixos-install --flake ~/dotfiles#<host> --root /mnt
```

The target's closure gets built into the SSD's store, which is part of why the
OS partition is sized generously.

## Reinstalling from scratch

Order matters here. Steps 4 and 5 are the ones that cause trouble if skipped.

**1. Stop the automounter.** It mounts new filesystems as disko creates them.

```bash
systemctl --user stop udiskie
```

**2. Wipe signatures.** disko skips `mkfs` on anything that already has a
filesystem signature, so leftovers mean a partition is silently left unformatted
and the run dies later with `wrong fs type, bad option, bad superblock`.
Partitions first, then the table — clearing the table hides signatures without
removing them.

```bash
sudo wipefs -a /dev/sda1 /dev/sda2 /dev/sda3
sudo wipefs -a /dev/sda
sudo blockdev --rereadpt /dev/sda
sudo rm -f /run/blkid/blkid.tab
```

Check each partition with `sudo blkid -p /dev/sdaN` — it must print nothing.
`lsblk` and plain `blkid` read caches and will report clean partitions that
aren't. If one still shows a signature, zero it and re-check:

```bash
sudo dd if=/dev/zero of=/dev/sdaN bs=1M count=64 oflag=direct status=progress
```

**3. Format and mount.** Asks for both passphrases.

```fish
set SCRIPT (nix build --no-link --print-out-paths \
  '.#nixosConfigurations.nomad.config.system.build.diskoScript')
sudo $SCRIPT
```

Then check `findmnt -R /mnt`. `/mnt/boot` must be **vfat**; if it says
`crypto_LUKS`, step 2 didn't take.

**4. Install.**

```bash
sudo nixos-install --flake /home/gdmsl/dotfiles#nomad --root /mnt
```

**5. Keyfile and password, before the first boot.** Your home is inside `carry`,
so without the keyfile it won't unlock, `/home/gdmsl` won't mount, and Home
Manager won't run at all. And with no password set, the login screen won't let
you in.

```bash
sudo nixos-enter --root /mnt
  mkdir -p /etc/secrets
  dd if=/dev/urandom of=/etc/secrets/carry.key bs=512 count=8
  chmod 0400 /etc/secrets/carry.key
  cryptsetup luksAddKey /dev/disk/by-partlabel/disk-nomad-carry /etc/secrets/carry.key
  passwd gdmsl
  exit
```

`luksAddKey` asks for the passphrase you set in step 3. That passphrase stays
valid, which is how you open the container on another machine.

**6. The repo, at exactly this path.** `dotfilesPath` in `flake.nix` is
`/home/gdmsl/dotfiles` and the `mkOutOfStoreSymlink` entries point at it, so
elsewhere those links dangle and nomad can't rebuild itself.

```bash
sudo cp -a /home/gdmsl/dotfiles /mnt/home/gdmsl/dotfiles
sudo chown -R 1000:100 /mnt/home/gdmsl
```

**7. Finish.**

```bash
sudo umount -R /mnt
sudo cryptsetup close carry
sudo cryptsetup close nomad-os
systemctl --user start udiskie
```

## When something's wrong

**Desktop starts but has no config** — niri comes up with its own defaults, no
kitty or starship setup. Home Manager activation failed partway. Activation is
one shell script, so a single failing step skips everything after it:

```bash
journalctl -u home-manager-gdmsl.service
```

Then `sudo nixos-rebuild switch --flake ~/dotfiles#nomad` once logged in.

**`~/Personal` or the home directory is missing** — `carry` didn't unlock. Both
mounts are `nofail`, so boot continues without them.

```bash
systemctl status systemd-cryptsetup@carry
ls -l /etc/secrets/carry.key        # 0400, and must exist
```

**TRIM isn't working** — needs the udev rule in `system/default.nix` matching the
drive, `allowDiscards` on the containers, and the enclosure to pass it through.
`lsblk -D` should show a non-zero `DISC-MAX`.
