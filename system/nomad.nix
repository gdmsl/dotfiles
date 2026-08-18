# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  nomad.nix — Host config for the portable SSD                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# The counterpart to hardware.nix. That file describes one known laptop; this
# one has to boot on machines it's never seen, so everything here avoids
# assuming anything about the hardware.
#
# Disk layout lives in ./disko-nomad.nix — partitions, LUKS and all the
# `fileSystems` entries. Don't add mount config here.

{ config, lib, pkgs, ... }:

{
  networking.hostName = "nomad";

  # ── Boot loader ─────────────────────────────────────────────────────────
  # GRUB, not systemd-boot. These two options are what make the disk portable,
  # so if it ever boots on only one machine, check them first:
  #
  #   efiInstallAsRemovable — installs to /EFI/BOOT/BOOTX64.EFI, the path
  #     firmware tries for removable media without needing a boot entry.
  #
  #   canTouchEfiVariables = false — writes nothing to the host's NVRAM. Left
  #     at its default of true, GRUB would add a "nomad" entry to whichever PC
  #     you plugged into, and boot properly only on that one.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev"; # UEFI only, so there's no MBR to install to

    # Each generation puts a kernel and initrd on the 2 GiB ESP, so cap how
    # many are kept or /boot fills up.
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = false;

  # If a machine's graphics won't come up, press `e` at the GRUB menu and add
  # `nomodeset` to the kernel line for that boot.

  # ── initrd drivers ──────────────────────────────────────────────────────
  # The initrd has to reach the SSD over whatever USB controller the machine
  # has, and take a passphrase from whatever keyboard it has, before the real
  # root exists. Missing drivers here look like a hang, not an error.
  boot.initrd.availableKernelModules = [
    # USB host controllers — xhci is USB3, ehci/ohci/uhci are older ports
    "xhci_pci"
    "ehci_pci"
    "ohci_pci"
    "uhci_hcd"
    # uas is the fast path; usb_storage is the fallback for enclosures whose
    # UAS implementation is buggy
    "uas"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    # Internal storage controllers, for installing onto another machine from
    # this one
    "nvme"
    "ahci"
    "sdhci_pci"
    # USB keyboards — without these you can't type the passphrase on a desktop
    "usbhid"
    "hid_generic"
    # dm-crypt plus AES acceleration
    "dm_crypt"
    "aesni_intel"
    "cryptd"
  ];

  # Both KVM modules: one matches the host CPU, the other fails to load and
  # logs a line. Harmless, and it means virtualisation works either way.
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

  # ── Firmware and CPU ────────────────────────────────────────────────────
  # This pulls in linux-firmware, which covers most Wi-Fi and GPU hardware.
  #
  # Not enableAllFirmware: that only adds Broadcom Bluetooth, legacy b43 Wi-Fi,
  # an Xbox dongle and FaceTime HD — all unfree, so each would need adding to
  # the allowUnfreePredicate lists. Add one by name if a machine needs it.
  hardware.enableRedistributableFirmware = true;

  # Both vendors, since the CPU isn't known ahead of time.
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  # amdgpu / i915 / nouveau are all in-tree and udev loads whichever matches
  # once the system is up. They're kept out of the initrd on purpose — early
  # KMS means picking a GPU in advance, which is what we're avoiding.

  nixpkgs.hostPlatform = "x86_64-linux";

  # ── Swap ────────────────────────────────────────────────────────────────
  # Compressed RAM instead of a swap partition: RAM size varies per machine,
  # and a hibernation image from one machine is useless on the next. That's
  # also why there's no boot.resumeDevice.
  zramSwap.enable = true;
  swapDevices = [ ];

  # Weekly TRIM. Needs allowDiscards on the containers (disko-nomad.nix) and
  # the udev rule in default.nix that enables discard on the USB bridge.
  services.fstrim.enable = true;

  # ── Unlocking the data container ────────────────────────────────────────
  # crypttab is read after the root filesystem is mounted, which is the point:
  # the keyfile only exists on the encrypted root, so it's useless to anyone
  # holding the disk. Putting this in boot.initrd.luks instead would place the
  # key on the unencrypted ESP. See disko-nomad.nix.
  #
  # The by-partlabel path comes from the disk and partition names in
  # disko-nomad.nix, so it's stable and predictable.
  #
  #   discard — pass TRIM through to the SSD
  #   nofail  — don't block boot if the container won't open
  #
  # This keyfile is a second key on the container; the passphrase you typed at
  # install time still works, which is how you open it on another machine.
  # Create it with:
  #
  #   mkdir -p /etc/secrets
  #   dd if=/dev/urandom of=/etc/secrets/carry.key bs=512 count=8
  #   chmod 0400 /etc/secrets/carry.key
  #   cryptsetup luksAddKey /dev/disk/by-partlabel/disk-nomad-carry \
  #     /etc/secrets/carry.key
  environment.etc."crypttab".text = ''
    carry /dev/disk/by-partlabel/disk-nomad-carry /etc/secrets/carry.key luks,discard,nofail
  '';

  # ── Turning off what belongs to the laptop ──────────────────────────────
  # system/default.nix is shared with yara and still enables a few things tied
  # to that hardware. Switch them off here rather than editing the shared file.

  # No fingerprint reader.
  services.fprintd.enable = lib.mkForce false;

  # ollama drags in the ROCm stack: a lot of disk space for a GPU that may not
  # be there.
  services.ollama.enable = lib.mkForce false;

  # thermald is Intel-only and fails on AMD. power-profiles-daemon, also in
  # the shared config, works on both and stays on.
  services.thermald.enable = lib.mkForce false;

  # Accelerometer and ambient light sensor — laptop hardware.
  hardware.sensor.iio.enable = lib.mkForce false;

  # Set to the release this was installed with, overriding the shared value.
  # It picks defaults for stateful services; leave it alone once installed.
  system.stateVersion = lib.mkForce "26.11";
}
