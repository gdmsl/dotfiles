{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # PATH
      set -x fish_user_paths
      fish_add_path ~/.local/bin
      fish_add_path ~/.luarocks/bin
      fish_add_path ~/.cargo/bin
      fish_add_path /var/lib/flatpak/exports/bin/

      # NPM
      set GOPATH "$HOME/Variable/go"
      set NPM_PACKAGES "$HOME/.npm-packages"
      set PATH $PATH $NPM_PACKAGES/bin
      set MANPATH $NPM_PACKAGES/share/man (manpath)
    '';

    interactiveShellInit = ''
      # Use fish inside nix-shell
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      # Exports
      set -gx EDITOR (which nvim)
      set -gx VISUAL $EDITOR
      set -gx SUDO_EDITOR $EDITOR
      set -x LESS -rF
      set -x MANPAGER "nvim +Man!"
      set -x MANROFFOPT -c

      # Cursor styles
      set -gx fish_vi_force_cursor 1
      set -gx fish_cursor_default block
      set -gx fish_cursor_insert line blink
      set -gx fish_cursor_visual block
      set -gx fish_cursor_replace_one underscore

      # Fish
      set fish_emoji_width 2

      # Pipe --help output through bat with syntax highlighting (folke's trick)
      abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"

      # Hook up direnv
      direnv hook fish | source
    '';

    shellAbbrs = {
      # Tmux
      t = "tmux";
      tc = "tmux attach";
      ta = "tmux attach -t";
      tad = "tmux attach -d -t";
      tl = "tmux ls";
      ts = "tmux new-session -s";
      tk = "tmux kill-session -t";
      mux = "tmuxinator";

      # Files & directories
      mv = "mv -iv";
      cp = "cp -riv";
      mkdir = "mkdir -vp";
      l = "ll";
      ncdu = "ncdu --color dark";

      # Editor
      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      sv = "sudoedit";
      vudo = "sudoedit";
      lv = "lazyvim";

      # Dev / Git
      gg = "lazygit";
      gl = "git l --color | devmoji --log --color | less -rXF";
      gs = "git st";
      gb = "git checkout -b";
      gc = "git commit";
      gpr = "gh pr checkout";
      gm = "git branch -l main | rg main > /dev/null 2>&1 && git checkout main || git checkout master";
      gcp = "git commit -p";
      gpp = "git push";
      gp = "git pull";

      # Other
      grep = "rg";
      df = "grc /bin/df -h";
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

    shellAliases = {
      ls = "eza --color=always --icons --group-directories-first";
      la = "eza --color=always --icons --group-directories-first --all";
      ll = "eza --color=always --icons --group-directories-first --all --long";
      tree = "eza --color=always --icons --group-directories-first --tree";
      vimpager = "nvim - -c \"lua require('util').colorize()\"";
      lazyvim = "NVIM_APPNAME=lazyvim nvim";
      bt = "coredumpctl -1 gdb -A '-ex \"bt\" -q -batch' 2>/dev/null | awk '/Program terminated with signal/,0' | bat -l cpp --no-pager --style plain";
    };

    functions = {
      # Git worktree: create or switch to a branch worktree
      gw = {
        description = "Create or switch to a git worktree";
        body = ''
          set -l branch $argv[1]
          if test -z "$branch"
              echo "Usage: gw <branch>"
              return 1
          end

          set -l repo (basename (git rev-parse --show-toplevel 2>/dev/null))
          set -l wt_base "$HOME/projects/git-worktrees/$repo"

          set -l wt_path "$wt_base/$branch"
          if test -d "$wt_path"
              cd "$wt_path"
          else
              git worktree add "$wt_path" -b "$branch" 2>/dev/null
              or git worktree add "$wt_path" "$branch"
              cd "$wt_path"
          end
        '';
      };

      # Git worktree: checkout a PR into a worktree via gh
      gpr = {
        description = "Checkout a GitHub PR into a git worktree";
        body = ''
          set -l pr $argv[1]
          if test -z "$pr"
              echo "Usage: gpr <pr-number>"
              return 1
          end

          set -l repo (basename (git rev-parse --show-toplevel 2>/dev/null))
          set -l wt_base "$HOME/projects/git-worktrees/$repo"
          set -l wt_path "$wt_base/pr-$pr"

          if test -d "$wt_path"
              cd "$wt_path"
          else
              set -l branch (gh pr view $pr --json headRefName -q '.headRefName')
              git fetch origin "pull/$pr/head:$branch" 2>/dev/null
              git worktree add "$wt_path" "$branch"
              cd "$wt_path"
          end
        '';
      };

      # Git worktree: fuzzy-pick a worktree with fzf
      gwl = {
        description = "Fuzzy-pick a git worktree";
        body = ''
          set -l wt (git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | fzf --height=40% --reverse)
          if test -n "$wt"
              cd "$wt"
          end
        '';
      };

      # Git worktree: remove a worktree
      gwr = {
        description = "Remove a git worktree";
        body = ''
          set -l wt_path (pwd)
          if test -n "$argv[1]"
              set wt_path $argv[1]
          end

          # Go back to main worktree before removing
          set -l main_wt (git worktree list --porcelain | grep '^worktree ' | head -1 | sed 's/^worktree //')
          cd "$main_wt"
          git worktree remove "$wt_path"
        '';
      };

      # Git worktree: toggle between main and latest worktree
      gwm = {
        description = "Toggle between main and latest git worktree";
        body = ''
          set -l worktrees (git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //')
          set -l main_wt $worktrees[1]
          set -l current (pwd)

          if test "$current" = "$main_wt"
              # Go to the last worktree
              set -l latest $worktrees[-1]
              if test "$latest" != "$main_wt"
                  cd "$latest"
              else
                  echo "No other worktrees"
              end
          else
              cd "$main_wt"
          end
        '';
      };

      # Focus the "dev" workspace and spawn a terminal if none exists (niri IPC)
      dev = {
        description = "Focus dev workspace, spawn terminal if empty";
        body = ''
          niri msg action focus-workspace "dev" 2>/dev/null
          # Check if there's already a window on the dev workspace
          set -l windows (niri msg --json windows 2>/dev/null | jq '[.[] | select(.workspace_name == "dev")] | length')
          if test "$windows" = "0" -o -z "$windows"
              niri msg action spawn -- kitty
          end
        '';
      };
    };

    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
  };
}
