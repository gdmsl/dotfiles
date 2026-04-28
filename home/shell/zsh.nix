# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  zsh.nix — Zsh shell configuration (fallback)                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Zsh is configured as a fallback shell — some environments (shared clusters,
# CI) default to it. Aliases come from ./_aliases.nix so all three shells
# stay in sync.
#
# Home Manager generates Zsh config files in $XDG_CONFIG_HOME/zsh/ (instead
# of cluttering $HOME with dotfiles) thanks to the dotDir option.

{ pkgs, config, ... }:

let
  aliases = import ./_aliases.nix;
in
{
  programs.zsh = {
    enable = true;
    # Store Zsh config in ~/.config/zsh instead of ~/
    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;   # don't store consecutive duplicate commands
      share = true;        # share history between concurrent sessions
      extended = false;
    };

    # Vi-mode keybindings (insert mode by default, Esc for normal mode)
    defaultKeymap = "viins";

    # Extra zshrc content
    initContent = ''
      # Reset zsh state (useful on shared clusters where system zshrc is weird)
      emulate -R zsh

      # Load local overrides (machine-specific config not in Nix)
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

      # Shorter timeout for key sequences (faster Esc in vi mode)
      export KEYTIMEOUT=1

      # History options
      setopt hist_reduce_blanks append_history

      # Shell options
      setopt auto_cd interactive_comments glob_dots

      # Tab completion (built-in, no plugin manager needed)
      autoload -Uz compinit && compinit
      zstyle ':completion:*' menu select                    # arrow-key menu
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
    '';

    shellAliases = aliases.commands // aliases.listing;
  };
}
