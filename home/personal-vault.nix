# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  personal-vault.nix — unlock/lock commands for ~/Personal                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# ~/Personal is encrypted and has to be mounted before use. Everything else in
# this config only checks that it *is a mountpoint*:
#
#   home/scripts.nix   — `mountpoint -q "$HOME/Personal"` before the -personal
#                        wrappers will run
#   home/services.nix  — Syncthing's ConditionPathIsMountPoint
#   home/xdg.nix       — Documents and Pictures live inside it
#
# None of them care how it got mounted, so different machines can use different
# mechanisms and only the two commands below change:
#
#   gocryptfs — a FUSE directory over ~/.personal-encrypted, unlocked on demand
#               without root.
#   system    — a btrfs subvolume mounted at boot (the portable SSD, where your
#               home is in the same encrypted container). Nothing to unlock.
#
# Default is gocryptfs, so anything that doesn't set this option keeps working.

{ config, lib, pkgs, ... }:

let
  cfg = config.my.personalVault;

  # Mount, then start the services whose state lives inside the vault:
  # Syncthing's config directory is in there, and the ssh-agent socket is
  # restarted so it picks up keys from it.
  gocryptfsCommands = {
    unlock-personal =
      "gocryptfs ~/.personal-encrypted ~/Personal"
      + " && systemctl --user start syncthing"
      + " && systemctl --user restart gcr-ssh-agent.socket";
    lock-personal = "systemctl --user stop syncthing; fusermount -u ~/Personal";
  };

  # Nothing to unlock: the container is already open, because the home
  # directory is inside it too. Closing it would pull the running session's
  # home out from under it, and unmounting only ~/Personal wouldn't encrypt
  # anything. The commands still exist so the names work and the guard messages
  # elsewhere still make sense.
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
    # All three shells. Fish gets abbreviations rather than aliases, matching
    # how _aliases.nix does it, so the real command is visible before you run
    # it.
    programs.fish.shellAbbrs = commands;
    programs.bash.shellAliases = commands;
    programs.zsh.shellAliases = commands;
  };
}
