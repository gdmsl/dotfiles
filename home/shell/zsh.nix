# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  zsh.nix — Zsh shell configuration (fallback)                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Zsh is configured as a fallback shell — some environments (shared clusters,
# CI) default to it. Shares the same aliases as Fish/Bash for consistency.
#
# Home Manager generates Zsh config files in $XDG_CONFIG_HOME/zsh/ (instead
# of cluttering $HOME with dotfiles) thanks to the dotDir option.

{ pkgs, config, ... }:

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

    # Same aliases as Fish and Bash
    shellAliases = {
      # Files & directories
      mv = "mv -iv";
      cp = "cp -riv";
      mkdir = "mkdir -vp";
      ls = "eza --color=always --icons --group-directories-first";
      la = "eza --color=always --icons --group-directories-first --all";
      ll = "eza --color=always --icons --group-directories-first --all --long";
      tree = "eza --color=always --icons --group-directories-first --tree";
      l = "ll";

      # Editor
      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      sv = "sudoedit";
      vudo = "sudoedit";

      # Tmux
      t = "tmux";
      tc = "tmux attach";
      ta = "tmux attach -t";
      tl = "tmux ls";
      ts = "tmux new-session -s";
      tk = "tmux kill-session -t";

      # Git
      gg = "lazygit";
      gs = "git st";
      gb = "git checkout -b";
      gc = "git commit";
      gcp = "git commit -p";
      gpp = "git push";
      gp = "git pull";

      # Modern CLI replacements
      grep = "rg";
      fda = "fd -IH";
      rga = "rg -uu";

      # systemctl
      s = "systemctl";
      su = "systemctl --user";
      ss = "systemctl status";
      sl = "systemctl --type service --state running";
      slu = "systemctl --user --type service --state running";
      sf = "systemctl --failed --all";

      # journalctl
      jb = "journalctl -b";
      jf = "journalctl -f";
      jg = "journalctl -b --grep";
      ju = "journalctl --unit";
      jm = "journalctl --user";

      # paru (AUR helper)
      p = "paru";
      pai = "paru -S";
      par = "paru -R";
      pas = "paru -Ss";
      pal = "paru -Q";
      paf = "paru -Ql";
      pao = "paru -Qo";
    };
  };
}
