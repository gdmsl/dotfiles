# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  disko-nomad.nix — Disk layout for the portable SSD                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# disko turns this description into the sgdisk / cryptsetup / mkfs commands that
# build the disk, and generates the `fileSystems` entries NixOS needs to mount
# it. One description, both jobs — so the disk and the mount config can't drift.
#
# Importing this file does nothing on its own. It only describes the disk;
# nothing is written until you run the formatter (see nomad-mount for the
# read-only counterpart that just mounts an existing disk).
#
# Before formatting, wipe the disk properly — disko skips mkfs on anything that
# already has a filesystem signature, so a leftover one from a previous layout
# means that partition is left untouched and the run dies later at the mount
# with "wrong fs type, bad option, bad superblock". Partitions first, then the
# table, because clearing the table hides the signatures without removing them:
#
#   sudo wipefs -a /dev/sdaN ...      # every partition
#   sudo wipefs -a /dev/sda           # then the table
#   sudo blkid -p /dev/sdaN           # must print nothing, for each one
#
# `blkid -p` probes the device directly. Plain `blkid` and `lsblk` both read
# caches and will happily report a partition as clean when it isn't.
#
#      2 GiB   ESP, FAT32      /boot                     unencrypted
#    158 GiB   LUKS "nomad-os" @ → /   @nix → /nix   @snapshots → /.snapshots
#    300 GiB   LUKS "carry"    @home → /home/gdmsl   @personal → ~/Personal
#   5.8 GiB    unallocated
#
# Two things worth knowing about the shape:
#
#   Home is on the *data* container, not the OS one. So you can reformat and
#   reinstall the OS without touching your files, and /nix gets its 158 GiB
#   without competing with your home.
#
#   The leftover ~5.8 GiB is deliberate. Blocks that are never written give the
#   SSD controller spare area to work with.
#
# `size` is in sgdisk units, where G means GiB, not GB. "300G" is 300 GiB. A
# "500 GB" drive is 465.8 GiB, so budget in GiB or the last partition won't fit.

{ ... }:

{
  disko.devices.disk.nomad = {
    type = "disk";

    # By-id, never /dev/sda: kernel names depend on enumeration order, so sda
    # could be the internal disk on another boot. This path is the drive's own
    # serial, so it also survives moving the SSD to a different enclosure.
    device = "/dev/disk/by-id/ata-CT500P3PSSD8_2401463EF214";

    content = {
      type = "gpt";
      partitions = {

        # ── EFI System Partition ──────────────────────────────────────────
        # Can't be encrypted: firmware reads the bootloader before any key
        # exists. 2 GiB rather than the usual 512 MiB because GRUB stores a
        # kernel + initrd here per generation, and this initrd is a fat one
        # (lots of drivers, see nomad.nix). Roughly 120 MiB × 10 generations.
        ESP = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        # ── OS container ──────────────────────────────────────────────────
        # Passphrase-unlocked in the initrd. Subvolumes instead of separate
        # partitions so / and /nix draw from the same 158 GiB. There's no @home
        # here — /home is just a directory inside @, a mount point for carry.
        os = {
          size = "158G";
          content = {
            type = "luks";
            name = "nomad-os";

            # Pin the KDF memory cost. cryptsetup otherwise calibrates it
            # against whatever machine does the formatting, and a value tuned on
            # a 32 GB laptop can be unusably slow to unlock on a small host.
            # 524288 KiB = 512 MiB.
            extraFormatArgs = [ "--pbkdf" "argon2id" "--pbkdf-memory" "524288" ];

            # Lets TRIM reach the SSD through dm-crypt. Without it, fstrim
            # inside the container silently does nothing. The cost is that an
            # attacker holding the disk can see which blocks are unused — not
            # what's in them.
            settings.allowDiscards = true;

            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nomad-os" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                };
                # The Nix store compresses well, and fewer bytes written is
                # easier on a budget SSD.
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                };
              };
            };
          };
        };

        # ── Data container ────────────────────────────────────────────────
        # Its own LUKS container rather than more subvolumes on nomad-os, so it
        # can be unlocked on another machine without involving the OS at all.
        carry = {
          size = "300G";
          content = {
            type = "luks";
            name = "carry";

            # Keep this false. It stops disko adding a boot.initrd.luks entry.
            #
            # The initrd sits on the unencrypted ESP, so any keyfile the initrd
            # can read is also readable by anyone holding the disk — which would
            # make encrypting this container pointless. Instead it's unlocked
            # later, from /etc/crypttab, with a keyfile that only exists once
            # the root filesystem is already decrypted. See nomad.nix.
            initrdUnlock = false;

            extraFormatArgs = [ "--pbkdf" "argon2id" "--pbkdf-memory" "524288" ];

            content = {
              type = "btrfs";
              extraArgs = [ "-L" "carry" ];
              # Two subvolumes sharing the 300 GiB, split by what they're for:
              #
              #   @home     — this machine's home: dotfiles, caches, the Home
              #               Manager symlinks into /nix/store. Only meaningful
              #               on nomad, since those store paths live here.
              #   @personal — the actual files, plus .claude / .codex / .gemini
              #               and the Firefox personal profile. Self-contained,
              #               so it can be mounted as ~/Personal elsewhere.
              #
              # nofail on both: if the container can't be unlocked, boot should
              # still finish. Home Manager's unit gets RequiresMountsFor on the
              # home directory automatically, so a missing @home means activation
              # is skipped rather than writing files that the real mount would
              # then hide.
              subvolumes = {
                "@home" = {
                  mountpoint = "/home/gdmsl";
                  mountOptions = [ "compress=zstd:1" "noatime" "nofail" ];
                };
                # Has to be a real mount, not a directory: the checks in
                # home/scripts.nix and home/services.nix both test whether
                # ~/Personal is a mountpoint.
                "@personal" = {
                  mountpoint = "/home/gdmsl/Personal";
                  mountOptions = [ "compress=zstd:1" "noatime" "nofail" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
