# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  bash.nix — Bash shell configuration (fallback)                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Bash is configured as a fallback shell — some scripts and tools expect it.
# Aliases come from ./_aliases.nix so they stay in lockstep with fish/zsh.
#
# Home Manager generates ~/.bashrc and ~/.bash_profile from these options.

{ pkgs, ... }:

let
  aliases = import ./_aliases.nix;
in
{
  programs.bash = {
    enable = true;

    # History settings — keep lots of history, deduplicate entries
    historyControl = [ "ignoreboth" "erasedups" ];  # ignore dupes and space-prefixed cmds
    historySize = 50000;
    historyFileSize = 50000;

    # Shell options (shopt)
    shellOptions = [
      "histappend"     # append to history file instead of overwriting
      "checkwinsize"   # update LINES/COLUMNS after each command
      "globstar"       # ** matches recursively in glob patterns
    ];

    # Extra bashrc content (runs after HM-generated config)
    initExtra = ''
      # Load local overrides (machine-specific config not in Nix)
      [ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

      # Vi mode for command-line editing (same as Fish)
      set -o vi

      # Flush history after each command so other terminals see it
      PROMPT_COMMAND="history -a; ''${PROMPT_COMMAND:-}"
    '';

    shellAliases = aliases.commands // aliases.listing;
  };
}
