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

  # system: ~/Personal is mounted by the system at boot, from a LUKS container
  # that is already open because the user's *home* lives in it too (nomad's
  # carry: @home → /home/gdmsl, @personal → ~/Personal).
  #
  # There is deliberately nothing to unlock or lock here. Closing the container
  # while logged in would pull the home directory out from under the session,
  # and "locking" only ~/Personal while home stays decrypted in the same
  # container would be security theatre. So these become informational — the
  # names still exist, because muscle memory and the guard messages in
  # home/scripts.nix both refer to them.
  systemCommands = {
    unlock-personal =
      "echo '~/Personal is mounted at boot on this host (carry/@personal) — nothing to unlock.'";
    lock-personal =
      "echo '~/Personal cannot be locked here: your home is in the same LUKS container.'";
  };

  commands =
    if cfg.backend == "system" then systemCommands else gocryptfsCommands;
in
{
  options.my.personalVault.backend = lib.mkOption {
    type = lib.types.enum [ "gocryptfs" "system" ];
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
