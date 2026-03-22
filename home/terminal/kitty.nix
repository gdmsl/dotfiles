{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "FiraCode Nerd Font Mono";
      size = 12;
    };

    settings = {
      bold_font = "auto";
      italic_font = "Maple Mono";
      bold_italic_font = "Maple Mono";
      disable_ligatures = "cursor";
      symbol_map = "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E634,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF Symbols Nerd Font Mono";

      # Misc
      scrollback_lines = 10000;
      touch_scroll_multiplier = "2.0";
      copy_on_select = "yes";
      enable_audio_bell = "no";
      remember_window_size = "yes";
      initial_window_width = 800;
      initial_window_height = 600;
      enabled_layouts = "Splits,Stack";
      hide_window_decorations = "no";
      tab_bar_style = "powerline";
      tab_separator = "\" \"";
      dynamic_background_opacity = "yes";
      scrollback_pager = "nvim";
      tab_title_template = "{title}{fmt.bold}{'  ' if num_windows > 1 and layout_name == 'stack' else ''}";
    };

    keybindings = {
      "kitty_mod+l" = "next_tab";
      "kitty_mod+h" = "previous_tab";
      "kitty_mod+m" = "toggle_layout stack";
      "kitty_mod+z" = "toggle_layout stack";
      "kitty_mod+enter" = "launch --location=split --cwd=current";
      "kitty_mod+\\" = "launch --location=vsplit --cwd=current";
      "kitty_mod+minus" = "launch --location=hsplit --cwd=current";
      "kitty_mod+left" = "neighboring_window left";
      "kitty_mod+right" = "neighboring_window right";
      "kitty_mod+up" = "neighboring_window up";
      "kitty_mod+down" = "neighboring_window down";
      "kitty_mod+r" = "show_scrollback";
    };

    # One Dark theme by Giuseppe Cesarano
    extraConfig = ''
      # Theme - One Dark
      background #1f2329
      foreground #a0a8b7

      cursor #cccccc

      color0 #282c34
      color1 #e06c75
      color2 #98c379
      color3 #e5c07b
      color4 #61afef
      color5 #be5046
      color6 #56b6c2
      color7 #979eab
      color8 #393e48
      color9 #d19a66
      color10 #56b6c2
      color11 #e5c07b
      color12 #61afef
      color13 #be5046
      color14 #56b6c2
      color15 #abb2bf

      selection_foreground #282c34
      selection_background #979eab
    '';
  };
}
