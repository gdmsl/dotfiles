# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  fish.nix — Fish shell configuration (primary shell)                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Fish is the primary interactive shell. This module configures:
#   - PATH setup and environment variables
#   - Abbreviations (abbrs) — like aliases but expand inline as you type
#   - Aliases — command substitutions that don't expand visually
#   - Functions — multi-line shell functions (for git worktrees, etc.)
#   - Plugins — Fish packages installed from nixpkgs
#
# Home Manager's `programs.fish` generates ~/.config/fish/config.fish from
# the options below. You never edit that file directly.

{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    # ── Shell init (runs for all fish instances, including scripts) ────────
    shellInit = ''
      # PATH — add directories for local scripts, language toolchains, etc.
      set -x fish_user_paths
      fish_add_path ~/.local/bin
      fish_add_path ~/.luarocks/bin
      fish_add_path ~/.cargo/bin
      fish_add_path /var/lib/flatpak/exports/bin/

      # Go and npm paths
      set GOPATH "$HOME/Variable/go"
      set NPM_PACKAGES "$HOME/.npm-packages"
      set PATH $PATH $NPM_PACKAGES/bin
      set MANPATH $NPM_PACKAGES/share/man (manpath)
    '';

    # ── Interactive shell init (runs only for interactive terminals) ───────
    interactiveShellInit = ''
      # any-nix-shell makes `nix-shell` drop you into fish instead of bash.
      # Without this, entering a nix-shell would switch you to bash.
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      # Editor settings
      set -gx EDITOR (which nvim)
      set -gx VISUAL $EDITOR
      set -gx SUDO_EDITOR $EDITOR
      set -x LESS -rF
      set -x MANPAGER "nvim +Man!"
      set -x MANROFFOPT -c

      # Vi-mode cursor styles — different cursor shapes indicate the current
      # vi mode (block = normal, line = insert, underscore = replace)
      set -gx fish_vi_force_cursor 1
      set -gx fish_cursor_default block
      set -gx fish_cursor_insert line blink
      set -gx fish_cursor_visual block
      set -gx fish_cursor_replace_one underscore

      # Emoji rendering width (helps alignment in prompt)
      set fish_emoji_width 2

      # Pipe --help output through bat with syntax highlighting (folke's trick)
      abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"

      # Hook up direnv (auto-loads .envrc files when you cd into a directory)
      direnv hook fish | source
    '';

    # ── Abbreviations ─────────────────────────────────────────────────────
    # Abbreviations expand inline as you type (you see the full command before
    # pressing Enter). This is nicer than aliases because you learn what the
    # commands actually do.
    shellAbbrs = {
      # Tmux session management
      t = "tmux";
      tc = "tmux attach";
      ta = "tmux attach -t";
      tad = "tmux attach -d -t";
      tl = "tmux ls";
      ts = "tmux new-session -s";
      tk = "tmux kill-session -t";
      mux = "tmuxinator";

      # Files & directories (safer defaults: -i = interactive, -v = verbose)
      mv = "mv -iv";
      cp = "cp -riv";
      mkdir = "mkdir -vp";
      l = "ll";
      ncdu = "ncdu --color dark";

      # Editor shortcuts
      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      sv = "sudoedit";
      vudo = "sudoedit";
      lv = "lazyvim";

      # Git shortcuts
      gg = "lazygit";
      gl = "git l --color | devmoji --log --color | less -rXF";
      gs = "git st";
      gb = "git checkout -b";
      gc = "git commit";
      gpr = "gh pr checkout";
      gm = "git branch -l main | rg main > /dev/null 2>&1 && git checkout main || git checkout master";
      gcp = "git commit -p";   # commit with interactive patch selection
      gpp = "git push";
      gp = "git pull";

      # Modern CLI tool replacements
      grep = "rg";
      df = "grc /bin/df -h";
      fda = "fd -IH";   # fd: include ignored and hidden files
      rga = "rg -uu";   # rg: search everything (no ignore, include hidden)

      # systemctl shortcuts
      s = "systemctl";
      su = "systemctl --user";
      ss = "systemctl status";
      sl = "systemctl --type service --state running";
      slu = "systemctl --user --type service --state running";
      sf = "systemctl --failed --all";

      # journalctl shortcuts (reading system logs)
      jb = "journalctl -b";            # current boot
      jf = "journalctl -f";            # follow (tail)
      jg = "journalctl -b --grep";     # grep current boot
      ju = "journalctl --unit";         # specific unit
      jm = "journalctl --user";         # user services

      # paru (AUR helper for Arch Linux)
      p = "paru";
      pai = "paru -S";    # install
      par = "paru -R";    # remove
      pas = "paru -Ss";   # search
      pal = "paru -Q";    # list installed
      paf = "paru -Ql";   # list files in package
      pao = "paru -Qo";   # which package owns a file
    };

    # ── Aliases ───────────────────────────────────────────────────────────
    # Unlike abbreviations, aliases don't expand inline — they stay as-is.
    # Used here for commands that are too complex to show expanded.
    shellAliases = {
      ls = "eza --color=always --icons --group-directories-first";
      la = "eza --color=always --icons --group-directories-first --all";
      ll = "eza --color=always --icons --group-directories-first --all --long";
      tree = "eza --color=always --icons --group-directories-first --tree";
      vimpager = "nvim - -c \"lua require('util').colorize()\"";
      lazyvim = "NVIM_APPNAME=lazyvim nvim";  # run a separate Neovim config
      bt = "coredumpctl -1 gdb -A '-ex \"bt\" -q -batch' 2>/dev/null | awk '/Program terminated with signal/,0' | bat -l cpp --no-pager --style plain";
    };

    # ── Functions ─────────────────────────────────────────────────────────
    # Multi-line Fish functions. Home Manager writes these to
    # ~/.config/fish/functions/<name>.fish automatically.
    functions = {
      # Create or switch to a git worktree for a branch.
      # Worktrees let you have multiple branches checked out simultaneously
      # in separate directories — useful for reviewing PRs while working.
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

      # Checkout a GitHub PR into a worktree (fetches the PR branch via gh CLI)
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

      # Fuzzy-pick a git worktree using fzf
      gwl = {
        description = "Fuzzy-pick a git worktree";
        body = ''
          set -l wt (git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | fzf --height=40% --reverse)
          if test -n "$wt"
              cd "$wt"
          end
        '';
      };

      # Remove a git worktree (defaults to current directory)
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

      # Toggle between main worktree and the most recently added one
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

      # Focus the "dev" workspace in Niri and spawn a terminal if empty.
      # Uses Niri's IPC (niri msg) to control the compositor.
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

    # ── Plugins ───────────────────────────────────────────────────────────
    # Fish plugins installed from nixpkgs. Each `src` points to a Nix
    # package that provides the plugin source.
    plugins = [
      {
        name = "done";     # sends a notification when long-running commands finish
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair"; # auto-close brackets, quotes, etc.
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";   # removes failed commands from history automatically
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
  };
}
