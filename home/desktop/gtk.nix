# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  gtk.nix — GTK theme, icons, cursor, and appearance                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Theming is spread across three places, all set here so they agree:
#
#   gtk3 / gtk4          theme, icons and cursor for GTK apps
#   dconf                some GTK apps read settings from here instead
#   home.pointerCursor   the cursor Wayland compositors use

{ pkgs, ... }:

{
  gtk = {
    enable = true;

    # ── GTK theme ─────────────────────────────────────────────────────
    # Same author as the icon theme below, so the two match.
    #
    # `name` has to be exactly the directory the package installs under
    # share/themes. Getting it wrong doesn't error — it just silently falls back
    # to the default theme. `ls ~/.nix-profile/share/themes` lists valid names.
    #
    # Home Manager installs `package` itself, so it isn't in packages.nix.
    theme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-gtk-theme;
    };

    # Ships scalable variants of most icons, so Qt renders cleanly at odd sizes
    # like the 19x19 noctalia asks for.
    iconTheme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-icon-theme;
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

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";     # subtle font hinting
    };

    # GTK4 is configured separately from GTK3.
    gtk4 = {
      theme = {
        name = "Colloid-Dark";
        package = pkgs.colloid-gtk-theme;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };

  # Home Manager refuses to overwrite files it didn't create. These are exactly
  # the files a GUI theme switcher like nwg-look writes, so without `force` a
  # single run of that tool would permanently block theme changes here.
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.dataFile."icons/default/index.theme".force = true;

  # ── dconf ───────────────────────────────────────────────────────────────
  # GNOME apps read their appearance from dconf rather than the GTK settings
  # files, so the same choices have to be repeated here.
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
  # The cursor the compositor itself draws. gtk.enable is false because the GTK
  # side is already set above.
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = false;
  };
}
