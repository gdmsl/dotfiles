{ pkgs, ... }:

{
  programs.bash = {
    enable = true;

    historyControl = [ "ignoreboth" "erasedups" ];
    historySize = 50000;
    historyFileSize = 50000;

    shellOptions = [
      "histappend"
      "checkwinsize"
      "globstar"
    ];

    initExtra = ''
      # Load local overrides
      [ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"

      # Vi mode
      set -o vi

      PROMPT_COMMAND="history -a; ''${PROMPT_COMMAND:-}"
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
