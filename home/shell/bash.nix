# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  bash.nix — Bash shell configuration (fallback)                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Bash is configured as a fallback shell — some scripts and tools expect it.
# It shares the same aliases as Fish/Zsh for a consistent experience.
#
# Home Manager generates ~/.bashrc and ~/.bash_profile from these options.

{ pkgs, ... }:

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

    # Aliases — same set as Fish and Zsh for consistency across shells
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
