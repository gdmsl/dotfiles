# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  disko-nomad.nix — Declarative disk layout for the portable SSD            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# `disko` turns this description into the actual partitioning/encryption/mkfs
# commands, instead of you running sgdisk + cryptsetup + mkfs by hand. The same
# description also generates the `fileSystems` entries NixOS needs at boot, so
# the layout and the mount config can never drift apart.
#
# Importing this file is harmless — it only *describes* the disk. Nothing is
# written until you explicitly run the disko formatter against it.
#
# Full rationale for every number and flag here lives in SSD_PLAN.md.
#
#   Measured capacity: 976,773,168 sectors = 465.762 GiB (a "500 GB" drive)
#
#      2 GiB   ESP, FAT32      /boot                 plaintext (firmware reads it)
#    158 GiB   LUKS "nomad-os" @ → /  @nix → /nix  @snapshots → /.snapshots
#    300 GiB   LUKS "carry"    @home → /home/gdmsl  @personal → ~/Personal
#   5.76 GiB   unallocated                          alignment + SSD spare area
#
# Home lives on the *data* container, not the OS one, so reinstalling the OS
# cannot destroy it — and /nix gets the 158 GiB to itself.
#
# NOTE ON UNITS: `size` is in sgdisk format, where G means **GiB**, not GB.
# "300G" is 300 GiB (= 322 GB). Do not "fix" these to decimal values.

{ ... }:

{
  disko.devices.disk.nomad = {
    type = "disk";

    # By-id, not /dev/sda. Kernel names depend on enumeration order and would
    # happily point at the internal KIOXIA on a different boot. This path is
    # keyed to the drive's own serial, so it also survives an enclosure swap.
    device = "/dev/disk/by-id/ata-CT500P3PSSD8_2401463EF214";

    content = {
      type = "gpt";
      partitions = {

        # ── EFI System Partition ──────────────────────────────────────────
        # Unencrypted by necessity: firmware has to read the bootloader before
        # any key exists. 2 GiB (not the usual 512 MiB) because GRUB keeps a
        # kernel + initrd per generation here, and this initrd is large — wide
        # module set plus enableAllFirmware. ~120 MiB × 10 generations.
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
        # Unlocked by passphrase in the initrd. btrfs subvolumes rather than
        # separate partitions so / and /nix share space freely. Note there is no
        # @home here: /home is a plain directory in @, acting only as the mount
        # parent for carry's @home.
        os = {
          size = "158G";
          content = {
            type = "luks";
            name = "nomad-os";

            # argon2id is the default, but pin the memory cost explicitly:
            # cryptsetup normally calibrates against the machine doing the
            # formatting. Formatted on yara (32 GB RAM), an uncapped cost can
            # make unlocking painfully slow — or impossible — on a low-RAM
            # host. 524288 KiB = 512 MiB.
            extraFormatArgs = [ "--pbkdf" "argon2id" "--pbkdf-memory" "524288" ];

            # Lets TRIM reach the SSD through dm-crypt. Without this, fstrim
            # inside the container is silently a no-op. Tradeoff: reveals which
            # blocks are unused (not their contents). See SSD_PLAN.md §4.3.
            settings.allowDiscards = true;

            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nomad-os" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                };
                # zstd earns its place twice over here: the Nix store is highly
                # compressible, and fewer bytes written means less write
                # amplification on a QLC drive behind a USB bridge.
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

        # ── Personal data container ───────────────────────────────────────
        # A separate container, not just another subvolume, so it can be
        # unlocked on yara without touching the OS — and so reinstalling the OS
        # can never endanger the data.
        carry = {
          size = "300G";
          content = {
            type = "luks";
            name = "carry";

            # CRITICAL: no boot.initrd.luks entry for this one.
            #
            # The initrd lives on the plaintext ESP. Any keyfile the initrd can
            # read is readable by whoever steals the disk, which would defeat
            # this container's encryption entirely. So it is unlocked in
            # *stage 2* instead, via /etc/crypttab, using a keyfile that only
            # exists on the already-decrypted root. See system/nomad.nix.
            initrdUnlock = false;

            extraFormatArgs = [ "--pbkdf" "argon2id" "--pbkdf-memory" "524288" ];

            content = {
              type = "btrfs";
              extraArgs = [ "-L" "carry" ];
              # Two subvolumes sharing the 300 GiB, with different lifetimes:
              #
              #   @home     — nomad's home: dotfiles, caches, the Home Manager
              #               symlinks into /nix/store, session state. Specific
              #               to this machine; does not travel.
              #   @personal — actual personal files, plus .claude/.codex/.gemini
              #               and the Firefox personal profile. This is the unit
              #               intended to mount as ~/Personal on other machines
              #               later, which is why it is separate.
              #
              # Putting home here rather than on nomad-os means reinstalling the
              # OS no longer destroys it, and /nix gets its 158 GiB to itself.
              #
              # nofail on both: a data container that fails to unlock must never
              # block boot. Home Manager gets RequiresMountsFor=/home/gdmsl for
              # free from its NixOS module, so if @home is missing, activation is
              # skipped rather than writing into a directory that later gets
              # shadowed by the real mount.
              subvolumes = {
                "@home" = {
                  mountpoint = "/home/gdmsl";
                  mountOptions = [ "compress=zstd:1" "noatime" "nofail" ];
                };
                # A real mount, not a directory — every guard in home/ tests
                # `mountpoint -q ~/Personal` or ConditionPathIsMountPoint, so
                # this has to be its own mount for them to keep working.
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
