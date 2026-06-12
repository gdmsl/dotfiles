# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  xdg.nix — XDG MIME types, default applications, and raw config files      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# XDG (Cross-Desktop Group) standards define how Linux desktops handle:
#   - MIME types — which app opens which file type
#   - Default applications — what happens when you click a link or file
#   - Config/data directories — ~/.config, ~/.local/share, etc.
#
# Home Manager's `xdg.mimeApps` generates ~/.config/mimeapps.list, which
# desktops read to determine default applications.
#
# The `.desktop` file names (like "firefox.desktop") correspond to .desktop
# entries installed by packages in /share/applications/.

{ config, pkgs, lib, ... }:

{
  xdg = {
    enable = true;

    # ── XDG user directories ──────────────────────────────────────────────
    # Writes ~/.config/user-dirs.dirs, which GTK/Qt apps read to populate the
    # file-manager sidebar and "Save as" shortcuts. Most live directly in
    # $HOME; Documents and Pictures live in the encrypted ~/Personal vault so
    # they sync via Syncthing.
    #
    # createDirectories is OFF on purpose: it would `mkdir` every path at
    # activation, including the vault ones. If the vault were locked during a
    # rebuild, that would create Documents/Pictures inside the bare mountpoint
    # and shadow the real data once unlocked. We scaffold the dirs ourselves
    # below, guarding the vault paths behind a mount check.
    userDirs = {
      enable = true;
      createDirectories = false;
      # Export XDG_*_DIR into the session environment so apps can read them
      # (the pre-26.05 default; set explicitly to silence the migration warning).
      setSessionVariables = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Personal/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Personal/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
      # Home Manager emits a non-standard XDG_PROJECTS_DIR (default ~/Projects).
      # Point it at the OneDrive-synced work projects tree, which already exists.
      # The key is the bare name (PROJECTS); HM expands it to XDG_PROJECTS_DIR.
      extraConfig.PROJECTS = "${config.home.homeDirectory}/QPerfect/Projects";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        # ── Web browser ───────────────────────────────────────────────
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/chrome" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";

        # ── Image viewer (Loupe / GNOME Image Viewer) ────────────────
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/bmp" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/jpg" = "org.gnome.Loupe.desktop";
        "image/pjpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/tiff" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "image/x-bmp" = "org.gnome.Loupe.desktop";
        "image/x-gray" = "org.gnome.Loupe.desktop";
        "image/x-icb" = "org.gnome.Loupe.desktop";
        "image/x-ico" = "org.gnome.Loupe.desktop";
        "image/x-png" = "org.gnome.Loupe.desktop";
        "image/x-portable-anymap" = "org.gnome.Loupe.desktop";
        "image/x-portable-bitmap" = "org.gnome.Loupe.desktop";
        "image/x-portable-graymap" = "org.gnome.Loupe.desktop";
        "image/x-portable-pixmap" = "org.gnome.Loupe.desktop";
        "image/x-xbitmap" = "org.gnome.Loupe.desktop";
        "image/x-xpixmap" = "org.gnome.Loupe.desktop";
        "image/x-pcx" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/svg+xml-compressed" = "org.gnome.Loupe.desktop";
        "image/vnd.wap.wbmp" = "org.gnome.Loupe.desktop";
        "image/x-icns" = "org.gnome.Loupe.desktop";

        # ── Text, PDF, files ──────────────────────────────────────────
        "text/plain" = "org.gnome.TextEditor.desktop";
        "application/pdf" = "org.pwmt.zathura.desktop";
        "x-scheme-handler/mailto" = "chromium.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        "inode/directory" = "org.gnome.Nautilus.desktop";

        # ── LibreOffice (documents, presentations, spreadsheets) ──────
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
        "application/msword" = "libreoffice-writer.desktop";
        "application/rtf" = "libreoffice-writer.desktop";
        "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";
        "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
        "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
        "application/vnd.ms-excel" = "libreoffice-calc.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";

        # ── Messaging ─────────────────────────────────────────────────
        "x-scheme-handler/sgnl" = "signal.desktop";
        "x-scheme-handler/signalcaptcha" = "signal.desktop";
      };
    };
  };

  # ── Raw config files ────────────────────────────────────────────────────
  # Deploy config files for apps with complex formats that aren't worth
  # nixifying (Python scripts, INI files, etc.).
  xdg.configFile = {
    "fastfetch/config.jsonc".source = ../raw/fastfetch/config.jsonc;
    "tofi/cheatsheet".source = ../raw/tofi/cheatsheet;
    "mpv/mpv.conf".source = ../raw/mpv/mpv.conf;
    "mpv/input.conf".source = ../raw/mpv/input.conf;
    "gdb/gdbinit".source = ../raw/gdb/gdbinit;
  };

  # ── Scaffold the XDG user directories ─────────────────────────────────────
  # Create the dirs declared in xdg.userDirs (createDirectories is off, see
  # above). The $HOME ones are always safe to create. The vault ones are only
  # created when ~/Personal is actually mounted, so we never write into the
  # bare mountpoint. `run` is Home Manager's wrapper that honours dry-run.
  home.activation.scaffoldUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Desktop" "$HOME/Public"
    if ${pkgs.util-linux}/bin/mountpoint -q "$HOME/Personal"; then
      run mkdir -p "$HOME/Personal/Documents" "$HOME/Personal/Pictures"
    fi
  '';
}
