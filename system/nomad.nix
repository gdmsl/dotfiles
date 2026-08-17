# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  nomad.nix — Host config for the portable encrypted SSD                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# This is the counterpart to hardware.nix (which describes yara). Where that
# file encodes *one known laptop*, this one has to boot on machines we've never
# seen — so it is deliberately hardware-agnostic.
#
# Pairs with ./disko-nomad.nix, which owns the partitions, LUKS containers and
# all the `fileSystems` entries. Nothing about disk layout belongs here.
#
# Design rationale for every decision: SSD_PLAN.md

{ config, lib, pkgs, ... }:

{
  networking.hostName = "nomad";

  # ── Boot loader: GRUB, UEFI-only, host-agnostic ─────────────────────────
  # GRUB rather than systemd-boot. The two options below are the single most
  # important thing in this file:
  #
  #   efiInstallAsRemovable = true
  #     Installs to the removable-media fallback path /EFI/BOOT/BOOTX64.EFI,
  #     which firmware tries without needing a boot entry. This is what makes
  #     the disk bootable on a machine that has never seen it.
  #
  #   canTouchEfiVariables = false
  #     Writes *nothing* to the host's NVRAM boot entries. The default (true)
  #     would scribble a "nomad" entry into whatever PC you plugged into, and
  #     the disk would then only really boot on that one machine.
  #
  # Get this pair wrong and everything else here is wasted.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev"; # UEFI only — no MBR/BIOS target, per SSD_PLAN.md §2

    # The ESP is 2 GiB and each generation stores a kernel + a large initrd
    # there. Bound the count so /boot cannot fill up mid-trip.
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = false;

  # If a host's graphics refuse to come up, press `e` at the GRUB menu and
  # append `nomodeset` to the kernel line for that one boot. Kept as a manual
  # escape hatch rather than a second menu entry — one less thing to break.

  # ── initrd: must find a USB disk on unfamiliar hardware ─────────────────
  # This list is the difference between booting and a black screen. The initrd
  # has to be able to reach the SSD over *any* controller and accept a
  # passphrase from *any* keyboard, before the real root exists.
  boot.initrd.availableKernelModules = [
    # USB host controllers — xhci is USB3, ehci/ohci/uhci are older ports
    "xhci_pci"
    "ehci_pci"
    "ohci_pci"
    "uhci_hcd"
    # USB mass storage: uas is the fast path (this enclosure uses it),
    # usb_storage is the fallback for bridges with broken UAS
    "uas"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    # Internal storage controllers — needed when *installing onto* another
    # machine from this system, and for hosts that expose the USB disk oddly
    "nvme"
    "ahci"
    "sdhci_pci"
    # USB keyboards. Without these you cannot type the LUKS passphrase on a
    # desktop, and the failure looks like a hang rather than an error.
    "usbhid"
    "hid_generic"
    # dm-crypt plus AES acceleration for both CPU vendors
    "dm_crypt"
    "aesni_intel"
    "cryptd"
  ];

  # Both KVM modules. Exactly one will match the host CPU; the other fails to
  # load and is logged, which is harmless. Including both means virtualisation
  # works wherever we land instead of depending on the vendor.
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

  # ── Firmware and CPU ────────────────────────────────────────────────────
  # linux-firmware ships with this and covers the overwhelming majority of
  # Wi-Fi and GPU hardware you'd actually meet.
  #
  # Deliberately NOT hardware.enableAllFirmware: it only adds Broadcom BT, the
  # legacy b43 Wi-Fi blobs, an Xbox dongle and FaceTime HD firmware — all
  # unfree, so each would need naming in the allowUnfreePredicate lists. If a
  # specific machine ever needs one, add that firmware package by name then.
  hardware.enableRedistributableFirmware = true;

  # Microcode for both vendors, since we don't know what we're booting on.
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  # GPU drivers (amdgpu / i915 / nouveau) are all in-tree and udev loads the
  # right one at stage 2. Deliberately not forced into the initrd: early KMS
  # for a *specific* GPU is precisely the kind of host assumption to avoid.

  nixpkgs.hostPlatform = "x86_64-linux";

  # ── Swap: zram, never a partition ───────────────────────────────────────
  # RAM differs per host, and a hibernation image written on one machine is
  # meaningless on the next — so there is no swap device and no resumeDevice.
  zramSwap.enable = true;
  swapDevices = [ ];

  # Weekly batched TRIM. Works because both LUKS containers set
  # allowDiscards (see disko-nomad.nix) and the udev rule in default.nix
  # forces the USB bridge's provisioning_mode to "unmap".
  services.fstrim.enable = true;

  # ── Stage-2 unlock of the data container ────────────────────────────────
  # NOT boot.initrd.luks — see the long comment in disko-nomad.nix. The initrd
  # sits on the plaintext ESP, so a keyfile it can read would be readable by
  # anyone who steals the disk. /etc/crypttab is processed in stage 2, once the
  # root filesystem (and therefore the keyfile) has already been decrypted.
  #
  # The by-partlabel path is set by disko from the disk/partition names, so it
  # is stable and known before the disk even exists.
  #
  #   luks    — the container format
  #   discard — pass TRIM through dm-crypt to the SSD
  #   nofail  — a locked or missing data container must never block boot
  #
  # The keyfile is keyslot 1; keyslot 0 stays a passphrase so the container can
  # also be opened on yara. Created during install, see SSD_PLAN.md §7.
  environment.etc."crypttab".text = ''
    carry /dev/disk/by-partlabel/disk-nomad-carry /etc/secrets/carry.key luks,discard,nofail
  '';

  # ── ~/Personal ──────────────────────────────────────────────────────────
  # A bind mount, not a symlink: the existing home config gates on
  # `mountpoint -q ~/Personal` (home/scripts.nix) and
  # ConditionPathIsMountPoint (home/services.nix). A bind mount satisfies both,
  # so every one of those guards keeps working unchanged.
  #
  # /mnt/carry stays the canonical path on every host — content on the SSD that
  # embeds absolute paths then works the same wherever it's plugged in.
  fileSystems."/home/gdmsl/Personal" = {
    device = "/mnt/carry";
    # "none" is how NixOS spells a bind mount — there's no filesystem to
    # mount here, we're re-exposing an already-mounted tree at a second path.
    fsType = "none";
    options = [ "bind" "nofail" ];
    depends = [ "/mnt/carry" ];
  };

  # ── Opting out of yara's hardware ───────────────────────────────────────
  # system/default.nix is the shared base and still carries a few things tied
  # to that specific laptop. Turning them off explicitly here is less risky
  # than refactoring the shared file (which would mean re-verifying yara).
  # SSD_PLAN.md §8 notes this as future cleanup.

  # No fingerprint reader on an unknown machine.
  services.fprintd.enable = lib.mkForce false;

  # ollama pulls the ROCm stack — a large closure that assumes a GPU we won't
  # have, on a disk where space is budgeted.
  services.ollama.enable = lib.mkForce false;

  # thermald is Intel-only and simply fails on AMD hosts. power-profiles-daemon
  # (also in the shared base) is vendor-neutral and stays enabled.
  services.thermald.enable = lib.mkForce false;

  # Accelerometer / ambient light sensor: yara has them, a random desktop
  # doesn't.
  hardware.sensor.iio.enable = lib.mkForce false;

  # A fresh install made on 26.11, so state defaults should match that release
  # rather than inheriting yara's original 24.11 from the shared base.
  system.stateVersion = lib.mkForce "26.11";
}
