# Hardware configuration for yara (ThinkPad E14 Gen 7)
# AMD Ryzen 7, 32GB RAM
# Run nixos-generate-config after install and update UUIDs
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # CPU
  hardware.cpu.amd.updateMicrocode = true;

  # TODO: replace with actual UUIDs after install
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/XXXX";
  #   fsType = "ext4";
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/XXXX";
  #   fsType = "vfat";
  # };
  #
  # boot.initrd.luks.devices."luks-root" = {
  #   device = "/dev/disk/by-uuid/XXXX";
  # };
  #
  # swapDevices = [
  #   { device = "/dev/disk/by-uuid/XXXX"; }
  # ];
}
