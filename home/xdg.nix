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

{ config, pkgs, ... }:

{
  xdg = {
    enable = true;

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
        "text/plain" = "com.system76.CosmicEdit.desktop";
        "application/pdf" = "org.pwmt.zathura.desktop";
        "x-scheme-handler/mailto" = "chromium.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        "inode/directory" = "com.system76.CosmicFiles.desktop";

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
    "mpv/mpv.conf".source = ../raw/mpv/mpv.conf;
    "mpv/input.conf".source = ../raw/mpv/input.conf;
    "gdb/gdbinit".source = ../raw/gdb/gdbinit;
  };
}
