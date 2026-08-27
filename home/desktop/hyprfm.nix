# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  hyprfm.nix — theming for the hyprfm file manager                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# hyprfm is a Qt *Quick* (QML) app, not Qt Widgets. Kvantum and the qt6ct
# palette in qt.nix therefore do not reach it at all — QML draws its own
# controls. What it does have is a TOML theme system of its own, so matching it
# to the rest of the desktop means restating the same palette here.
#
# Themes live in ~/.config/hyprfm/themes/*.toml and are picked by name (the
# filename without .toml) from config.toml. Both are written by Home Manager
# below, with the same Tokyo Night values qt.nix uses.
#
# One consequence of managing config.toml here: it becomes a read-only symlink
# into the Nix store, so hyprfm's in-app settings screen can't write to it —
# the same trade-off already taken for noctalia's config.toml. Change settings
# in this file and rebuild, or drop the config.toml block to hand hyprfm back
# its own file and select the theme from the picker instead.

{ ... }:

{
  xdg.configFile = {
    # Colour keys hyprfm understands; any key left out falls back to its
    # default. `themes/` is searched before the bundled themes, so this name
    # would also shadow a stock theme called tokyo-night.
    "hyprfm/themes/tokyo-night.toml".text = ''
      [colors]
      base    = "#1a1b26"
      mantle  = "#16161e"
      crust   = "#15161e"
      surface = "#24283b"
      overlay = "#353d57"
      text    = "#c0caf5"
      subtext = "#9aa5ce"
      muted   = "#565f89"
      accent  = "#7aa2f7"
      success = "#9ece6a"
      warning = "#e0af68"
      error   = "#f7768e"
    '';

    "hyprfm/config.toml".text = ''
      # Managed by home/desktop/hyprfm.nix.
      # hyprfm regenerates config.toml.sample next to this file on every start;
      # read that for the full, commented set of options.

      # Without this, hyprfm follows the system light/dark hint rather than a
      # named theme — which is what left it looking light.
      theme = "tokyo-night"

      # Matches gtk.nix and the Qt font in qt.nix, so text is consistent across
      # all three toolkits. Left empty, hyprfm would take the Qt desktop font,
      # which is the same value — this just makes it explicit.
      font_family = "Inter"

      icon_theme = "Colloid-Dark"
    '';
  };
}
