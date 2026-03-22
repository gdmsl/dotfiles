{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    mouse = true;
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      cpu
      better-mouse-mode
    ];

    extraConfig = ''
      # Terminal overrides
      set -ga terminal-overrides ",*256col*:Tc"
      set-option -ga terminal-overrides ",alacritty:Tc"

      set -g update-environment "DISPLAY SSH_ASKPASS SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY SSH_AUTH_SOCK"

      # Sidebar (tree)
      set -g @sidebar-tree-command 'tree -C'

      # Pane base index
      setw -g pane-base-index 1

      # tmux nova theme
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
