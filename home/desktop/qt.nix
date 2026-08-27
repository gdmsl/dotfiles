# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  qt.nix — Qt appearance, matched to the GTK side                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Qt has no equivalent of the GTK theme setting, so making Qt apps look like the
# rest of the desktop takes three cooperating pieces:
#
#   platform theme   qt6ct, which supplies fonts, icon theme and palette to Qt.
#                    Selected by QT_QPA_PLATFORMTHEME, set by the module below.
#   widget style     Kvantum, an SVG-driven engine that draws the widgets.
#                    Selected by QT_STYLE_OVERRIDE.
#   colour palette   a qt6ct colour-scheme file, generated here from the same
#                    Tokyo Night values noctalia uses.
#
# Home Manager's `qt` module owns all three environment variables and writes
# qt5ct.conf / qt6ct.conf from the attrsets below, which is why there are no
# hand-written copies of those files in raw/ anymore.
#
# A caveat worth knowing: Kvantum and qt6ct only style Qt *Widgets* apps. Qt
# Quick / QML apps draw themselves and ignore both — hyprfm is one, and gets its
# own matching theme in hyprfm.nix.

{ pkgs, ... }:

let
  # ── Tokyo Night ───────────────────────────────────────────────────────────
  # Taken from noctalia's own palette (~/.config/noctalia/colors.json) so the
  # shell, the Qt apps and hyprfm all land on the same colours.
  tn = {
    bg        = "1a1b26";  # window
    bgDark    = "16161e";  # base / text entry background
    bgDarker  = "15161e";  # shadow
    surface   = "24283b";  # buttons, alternate rows, tooltips
    overlay   = "353d57";  # midlight
    light     = "414868";
    text      = "c0caf5";
    subtext   = "9aa5ce";
    muted     = "565f89";  # disabled text, placeholders
    accent    = "7aa2f7";  # primary blue
    purple    = "bb9af7";  # visited links
  };

  # qt6ct stores a palette as 21 comma-separated #AARRGGBB values, in
  # QPalette::ColorRole order. Named here so the list stays readable:
  #   0 WindowText  1 Button     2 Light      3 Midlight  4 Dark    5 Mid
  #   6 Text        7 BrightText 8 ButtonText 9 Base     10 Window 11 Shadow
  #  12 Highlight  13 HighlightedText  14 Link  15 LinkVisited  16 AlternateBase
  #  17 NoRole     18 ToolTipBase      19 ToolTipText    20 PlaceholderText
  palette = { windowText, text, buttonText, highlightedText }: builtins.concatStringsSep ", " [
    "#ff${windowText}" "#ff${tn.surface}" "#ff${tn.light}"   "#ff${tn.overlay}"
    "#ff${tn.bgDark}"  "#ff${tn.surface}" "#ff${text}"       "#ffffffff"
    "#ff${buttonText}" "#ff${tn.bgDark}"  "#ff${tn.bg}"      "#ff${tn.bgDarker}"
    "#ff${tn.accent}"  "#ff${highlightedText}" "#ff${tn.accent}" "#ff${tn.purple}"
    "#ff${tn.surface}" "#ff${tn.bg}"      "#ff${tn.surface}" "#ff${tn.text}"
    "#80${tn.text}"
  ];

  colorScheme = pkgs.writeText "tokyo-night.conf" ''
    [ColorScheme]
    active_colors=${palette {
      windowText = tn.text; text = tn.text; buttonText = tn.text;
      highlightedText = tn.bgDark;
    }}
    inactive_colors=${palette {
      windowText = tn.subtext; text = tn.subtext; buttonText = tn.subtext;
      highlightedText = tn.bgDark;
    }}
    disabled_colors=${palette {
      windowText = tn.muted; text = tn.muted; buttonText = tn.muted;
      highlightedText = tn.muted;
    }}
  '';

  # Not in nixpkgs. A Kvantum theme is just a .kvconfig plus the .svg it draws
  # widgets from, and Kvantum reads them straight out of ~/.config/Kvantum/,
  # so a plain source fetch is enough — no derivation to build.
  kvantumTokyoNight = pkgs.fetchFromGitHub {
    owner = "0xsch1zo";
    repo = "Kvantum-Tokyo-Night";
    rev = "539dacded0dae37425617d193614ee9f762da8fa";
    hash = "sha256-mcxTggpj2SVhHur7xzZxHeOZO7QtWCZsq0m6eJKy6aQ=";
  };
  kvTheme = "Kvantum-Tokyo-Night";

  # Shared by qt5ct and qt6ct. `general` matches gtk.nix's Inter 11 so text is
  # the same size and shape either side of the toolkit divide; `fixed` is the
  # monospace slot, which wants the terminal font rather than Inter.
  qtctSettings = {
    Appearance = {
      style = "kvantum";
      icon_theme = "Colloid-Dark";
      standard_dialogs = "xdgdesktopportal";
      custom_palette = true;
      color_scheme_path = "${colorScheme}";
    };
    Fonts = {
      general = ''"Inter,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
      fixed = ''"FiraCode Nerd Font Mono,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"'';
    };
    Interface = {
      activate_item_on_single_click = 1;
      buttonbox_layout = 3;
      cursor_flash_time = 1200;
      dialog_buttons_have_icons = 1;
      double_click_interval = 400;
      keyboard_scheme = 2;
      menus_have_icons = true;
      show_shortcuts_in_context_menus = true;
      toolbutton_style = 4;
      underline_shortcut = 1;
      wheel_scroll_lines = 3;
    };
  };
in

{
  qt = {
    enable = true;

    # "qtct" resolves to QT_QPA_PLATFORMTHEME=qt5ct. That name looks wrong for
    # Qt6, but qt6ct's plugin registers both the qt5ct and qt6ct keys, so the
    # one value drives Qt5 and Qt6 alike — which the two compositor configs
    # previously disagreed about.
    platformTheme.name = "qtct";

    # Sets QT_STYLE_OVERRIDE and installs the Kvantum engine for Qt5 and Qt6.
    style.name = "kvantum";

    qt5ctSettings = qtctSettings;
    qt6ctSettings = qtctSettings;
  };

  # Kvantum reads user themes from ~/.config/Kvantum/<Theme>/<Theme>.kvconfig,
  # which is why the theme is linked in rather than installed as a package.
  xdg.configFile = {
    "Kvantum/${kvTheme}/${kvTheme}.kvconfig".source = "${kvantumTokyoNight}/${kvTheme}/${kvTheme}.kvconfig";
    "Kvantum/${kvTheme}/${kvTheme}.svg".source = "${kvantumTokyoNight}/${kvTheme}/${kvTheme}.svg";

    # Which of the installed themes Kvantum actually draws with.
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=${kvTheme}
    '';
  };
}
