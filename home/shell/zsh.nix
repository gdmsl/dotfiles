{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
      extended = false;
    };

    defaultKeymap = "viins";

    initExtra = ''
      # Reset zsh state (useful on shared clusters)
      emulate -R zsh

      # Load local overrides
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

      export KEYTIMEOUT=1

      # History options
      setopt hist_reduce_blanks append_history

      # Shell options
      setopt auto_cd interactive_comments glob_dots

      # Completion (built-in, no plugin manager needed)
      autoload -Uz compinit && compinit
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    '';

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

      # Grep / find
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

      # paru
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
