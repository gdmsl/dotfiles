# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  personal-vault.nix — unlock/lock commands for the ~/Personal vault        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# ~/Personal is an encrypted directory that has to be unlocked before use. The
# rest of this config only ever cares that it *is a mountpoint*:
#
#   home/scripts.nix   — `mountpoint -q "$HOME/Personal"` guards
#   home/services.nix  — Syncthing's ConditionPathIsMountPoint
#   home/xdg.nix       — XDG Documents/Pictures point inside it
#
# None of those care *how* it got mounted, which is why two different machines
# can use two different mechanisms with no other changes:
#
#   gocryptfs — yara. A FUSE overlay over ~/.personal-encrypted. Rootless.
#   luks      — nomad. The SSD's LUKS data container, mounted by the system at
#               /mnt/carry and bind-mounted to ~/Personal (see system/nomad.nix),
#               so unlocking is about the *container*, not a user-space mount.
#
# Only the two commands below differ between them. Default is gocryptfs, so
# yara and the standalone home-manager profiles are unaffected.

{ config, lib, pkgs, ... }:

let
  cfg = config.my.personalVault;

  # gocryptfs: mount the FUSE overlay, then bring up the services that store
  # their state inside the vault. Syncthing's --home lives in there, and the
  # ssh-agent socket is restarted so it picks up keys from the vault.
  gocryptfsCommands = {
    unlock-personal =
      "gocryptfs ~/.personal-encrypted ~/Personal"
      + " && systemctl --user start syncthing"
      + " && systemctl --user restart gcr-ssh-agent.socket";
    lock-personal = "systemctl --user stop syncthing; fusermount -u ~/Personal";
  };

  # LUKS: the container is opened and mounted at the system level, and
  # ~/Personal is a bind mount of it — so "locking" means unmounting the bind
  # *and* closing the container, in that order.
  #
  # udisksctl rather than `sudo cryptsetup`: it goes through polkit, so this
  # stays a rootless operation like the gocryptfs version. On nomad the
  # container is normally already open from boot via /etc/crypttab; these are
  # for re-opening it after a manual lock.
  luksCommands = {
    unlock-personal =
      "udisksctl unlock -b /dev/disk/by-partlabel/disk-nomad-carry"
      + " && systemctl --user start syncthing";
    lock-personal =
      "systemctl --user stop syncthing"
      + "; udisksctl lock -b /dev/disk/by-partlabel/disk-nomad-carry";
  };

  commands = if cfg.backend == "luks" then luksCommands else gocryptfsCommands;
in
{
  options.my.personalVault.backend = lib.mkOption {
    type = lib.types.enum [ "gocryptfs" "luks" ];
    default = "gocryptfs";
    description = ''
      How ~/Personal is encrypted on this machine. Selects which
      unlock-personal / lock-personal commands get installed.
    '';
  };

  config = {
    # Installed for all three shells so the commands exist wherever you are.
    # Fish gets them as abbreviations (matching how home/shell/_aliases.nix
    # treats `commands`) so the full command is visible before you hit Enter.
    programs.fish.shellAbbrs = commands;
    programs.bash.shellAliases = commands;
    programs.zsh.shellAliases = commands;
  };
}
