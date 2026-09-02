# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  rbw.nix — rbw, a command-line client for Bitwarden / Vaultwarden           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Two binaries come out of this. `rbw` is the command you type; `rbw-agent` is
# a daemon it starts on demand, which holds the decrypted vault key in memory
# so the master password is asked for once rather than on every lookup.
#
# First run, in this order:
#
#   rbw login    — asks for the master password, registers this machine
#   rbw sync     — downloads the vault into the local cache
#
# Then, day to day:
#
#   rbw ls               — list entry names
#   rbw get <name>       — print one password to stdout
#   rbw get <name> --full  — same, plus the entry's notes
#   rbw search <term>    — find entries when you don't recall the exact name
#   rbw add <name>       — opens $EDITOR; first line is the password, the rest
#                          becomes the note
#   rbw lock             — forget the key now instead of waiting for the timeout
#
# Where the state lives:
#
#   ~/.config/rbw/config.json   rendered by Home Manager from the `settings`
#                               block below, so it is a read-only symlink into
#                               the Nix store. `rbw config set …` therefore
#                               fails — edit this file and rebuild instead.
#
#   ~/.local/share/rbw/         the encrypted vault cache and this machine's
#                               device id. rbw writes here at runtime, and
#                               nothing in this file touches it.

{ pkgs, lib, ... }:

{
  programs.rbw = {
    enable = true;

    settings = {
      email = "guido.masella@gmail.com";

      # The self-hosted Vaultwarden. `.home.arpa` is the domain RFC 8375 sets
      # aside for home networks, so the name only resolves on the LAN: away
      # from home `rbw sync` fails, while `rbw get` keeps answering out of the
      # cache in ~/.local/share/rbw.
      base_url = "https://vault.home.arpa/";

      # Seconds the agent holds the key before asking again, and seconds
      # between background syncs. Both are rbw's own defaults, spelled out
      # here because they're the two knobs worth reaching for.
      lock_timeout = 3600;
      sync_interval = 3600;

      # The dialog that asks for the master password. Qt, because qt6ct and
      # Kvantum already theme it — see desktop/qt.nix. mkDefault leaves it
      # overridable, which tty.nix does.
      pinentry = lib.mkDefault pkgs.pinentry-qt;
    };
  };
}
