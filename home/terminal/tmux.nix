# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  tmux.nix — tmux terminal multiplexer                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# tmux lets you have multiple terminal sessions inside one window, detach
# them, and reattach later (great for remote work over SSH).
#
# Home Manager's `programs.tmux` generates ~/.config/tmux/tmux.conf.
# Plugins are installed from nixpkgs and loaded automatically.

{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;                # start window/pane numbering at 1 (not 0)
    mouse = true;                 # enable mouse for scrolling and pane selection
    terminal = "screen-256color"; # tell tmux about 256-color support

    # Plugins installed from nixpkgs
    plugins = with pkgs.tmuxPlugins; [
      sensible         # sane default settings (escape-time, history, etc.)
      yank             # copy-mode selections to the system clipboard
                       # (detects wl-copy on its own, so no bindings needed)
      cpu              # CPU/RAM usage in status bar
      better-mouse-mode
    ];

    # Raw tmux config appended after the generated settings
    extraConfig = ''
      # True color support for terminals that advertise it
      set -ga terminal-overrides ",*256col*:Tc"
      set-option -ga terminal-overrides ",alacritty:Tc"

      # Pass through display/SSH environment variables when attaching.
      # WAYLAND_DISPLAY matters for the clipboard: wl-copy needs it to find the
      # compositor socket. A session detached and reattached under a new
      # compositor instance would otherwise keep the stale value and fail.
      set -g update-environment "DISPLAY WAYLAND_DISPLAY SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY SSH_AUTH_SOCK"

      # ── Clipboard ────────────────────────────────────────────────────
      # Let programs inside tmux set the outer terminal's clipboard with the
      # OSC 52 escape sequence, and pass it up to kitty. Without this tmux
      # swallows the sequence. Locally Neovim uses wl-copy directly and never
      # needs it; it matters over SSH, where a remote Neovim has no wl-copy to
      # call and falls back to OSC 52.
      set -s set-clipboard on

      # Sidebar plugin: use tree command for file tree view
      set -g @sidebar-tree-command 'tree -C'

      # Match pane numbering with window numbering
      setw -g pane-base-index 1

      # ── Nova theme (status bar) ──────────────────────────────────────
      set -gw window-status-current-style bold
      set -g @nova-rows 0
      set -g @nova-nerdfonts true
      set -g @nova-pane "#I#{?pane_in_mode,  #{pane_mode},}  #W"
      set -g @nova-segment-mode "#{?client_prefix,Ω,ω}"
      set -g @nova-segment-session "#{session_name}"
      set -g @nova-segment-cpu " #(~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh) #(~/.tmux/plugins/tmux-cpu/scripts/ram_percentage.sh)"
      set -g @nova-segment-whoami "#(whoami)@#h"
      set -g @nova-segments-0-left "session"
      set -g @nova-segments-0-right "cpu whoami"
    '';
  };
}
