# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  fish.nix — Fish shell configuration (primary shell)                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Fish is the primary interactive shell. Common aliases live in ./_aliases.nix
# and are installed here as *abbreviations* so they expand inline as you type
# (instead of staying hidden behind an alias name). Fish-only shortcuts and
# multi-line functions live below.
#
# Home Manager already deploys home.sessionVariables and home.sessionPath via
# ~/.config/fish/conf.d/hm-session-vars.fish, so this module no longer
# re-exports EDITOR/LESS/PATH — that was just duplicating what HM emits.

{ pkgs, ... }:

let
  aliases = import ./_aliases.nix;
in
{
  programs.fish = {
    enable = true;

    # ── Interactive shell init (interactive terminals only) ────────────────
    interactiveShellInit = ''
      # any-nix-shell makes `nix-shell` drop you into fish instead of bash.
      # Without this, entering a nix-shell would switch you to bash.
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      # Vi-mode cursor styles — different cursor shapes indicate the current
      # vi mode (block = normal, line = insert, underscore = replace).
      set -gx fish_vi_force_cursor 1
      set -gx fish_cursor_default block
      set -gx fish_cursor_insert line blink
      set -gx fish_cursor_visual block
      set -gx fish_cursor_replace_one underscore

      # Emoji rendering width (helps alignment in prompt)
      set fish_emoji_width 2

      # Pipe --help output through bat with syntax highlighting (folke's trick)
      abbr -a --position anywhere --set-cursor -- -h "-h 2>&1 | bat --plain --language=help"

      # Prepend npm man pages to MANPATH. We do this in fish (not in
      # home.sessionVariables) because computing the existing MANPATH
      # requires calling the `manpath` builtin at shell-init time.
      set -x MANPATH "$HOME/.npm-packages/share/man" (manpath)
    '';

    # ── Abbreviations ────────────────────────────────────────────────────
    # `commands` from _aliases.nix — same shortcuts as bash/zsh. Fish gets
    # them as abbrs so the full command shows up before you hit Enter.
    shellAbbrs = aliases.commands // {
      # Fish-only conveniences
      tad = "tmux attach -d -t";
      mux = "tmuxinator";
      ncdu = "ncdu --color dark";
      df = "grc /bin/df -h";
      gl = "git l --color | devmoji --log --color | less -rXF";
      gm = "git branch -l main | rg main > /dev/null 2>&1 && git checkout main || git checkout master";
      lv = "lazyvim";
    };

    # ── Aliases ──────────────────────────────────────────────────────────
    # Use plain aliases for commands we never want to see expanded inline
    # (long eza invocations, multi-pipe one-liners).
    shellAliases = aliases.listing // {
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
    # Fish plugins installed from nixpkgs.
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
