# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  gtk.nix — GTK theme, icons, cursor, and appearance                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Linux desktop theming is split across multiple systems:
#   - GTK3/GTK4 — theme, icons, cursor for GNOME/GTK apps
#   - dconf      — GNOME settings database (some GTK apps read this)
#   - home.pointerCursor — cursor theme for Wayland compositors
#
# Home Manager writes the correct settings files for each system so all
# apps pick up the same theme consistently.

{ pkgs, ... }:

{
  gtk = {
    enable = true;

    # ── GTK theme ─────────────────────────────────────────────────────
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;  # Nix installs the theme package
    };

    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = "Inter";
      size = 11;
    };

    # GTK3-specific overrides
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";     # subtle font hinting
    };

    # GTK4 has its own theme mechanism
    gtk4 = {
      theme = {
        name = "Tokyonight-Dark";
        package = pkgs.tokyonight-gtk-theme;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };

  # Force overwrite — Home Manager won't overwrite existing files by default.
  # These force flags ensure our theme always takes effect even if files
  # were previously created by another tool (like nwg-look).
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.dataFile."icons/default/index.theme".force = true;

  # ── dconf settings ──────────────────────────────────────────────────────
  # Some GNOME apps (even on non-GNOME desktops) read theme settings from
  # the dconf database. This ensures they respect our dark theme preference.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "Inter 11";
      font-hinting = "slight";
      cursor-size = 24;
      text-scaling-factor = 1.0;
    };
  };

  # ── Wayland cursor ──────────────────────────────────────────────────────
  # home.pointerCursor sets the cursor for Wayland compositors (Niri, Hyprland).
  # gtk.enable = false avoids duplicate cursor config (already handled above).
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = false;
  };
}
