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
#   ~/.cache/rbw/               the synced vault, one file per server+account.
#                               Entries sit in there as Bitwarden
#                               cipherstrings and are decrypted on read; the
#                               API tokens beside them are not. `rbw purge`
#                               stops the agent and deletes this.
#
#   ~/.local/share/rbw/         this machine's device id, written once by
#                               `rbw login`, plus the agent's log files.
#
#   $XDG_RUNTIME_DIR/rbw/       the agent's socket and pidfile. That is a
#                               tmpfs, so rebooting drops them along with the
#                               decrypted key the agent was holding. The
#                               registration and the synced vault above are on
#                               disk and survive, so what a reboot costs is
#                               one master password prompt on next use, not
#                               another `rbw login`.
#
# rbw creates all three of those directories 0700 itself.

{ pkgs, lib, ... }:

{
  programs.rbw = {
    enable = true;

    settings = {
      email = "guido.masella@gmail.com";

      # The self-hosted Vaultwarden. `.home.arpa` is the domain RFC 8375 sets
      # aside for home networks, so the name only resolves on the LAN: away
      # from home `rbw sync` fails, while `rbw get` keeps answering out of the
      # cache in ~/.cache/rbw.
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

  # ── Fish abbreviations ──────────────────────────────────────────────────
  # `command = "rbw"` is what scopes these to a subcommand: fish expands the
  # word only where it sits as an argument to rbw, so typing plain `ls` still
  # reaches the eza alias in shell/_aliases.nix. The attribute name is just a
  # Nix key — `name` is the word you actually type.
  #
  # Abbreviations rather than aliases, as everywhere else in this config, so
  # the flags land on the command line before it runs and a one-off variation
  # is an edit away rather than a different command. Fish only: scoping an
  # expansion to one command has no bash or zsh equivalent.
  #
  # Both expansions lead with the id. `rbw get` takes a name, a URI or an id
  # as its first argument and works out which by trying to parse it, and the
  # id is the only one of the three guaranteed to hit a single entry — so
  # printing it means every ambiguous result carries its own fix. Leading with
  # it also lines the name column up, since a UUID is always 36 characters
  # wide and the names after it therefore all start at the same tab stop.
  programs.fish.shellAbbrs = {
    # `--fields` defaults to name alone, which is exactly the half that isn't
    # unique when two entries share it. The username comes along because it is
    # what `rbw get <name> <user>` takes to disambiguate by hand.
    rbw-search = {
      name = "search";
      command = "rbw";
      expansion = "search --fields id,name,user";
    };

    # Browsing the whole vault rather than looking one thing up, so the folder
    # earns its column here.
    rbw-ls = {
      name = "ls";
      command = "rbw";
      expansion = "ls --fields id,name,user,folder";
    };
  };
}
