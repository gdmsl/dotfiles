{ config, pkgs, ... }:

{
  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
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
        "image/jpeg" = "oculante.desktop";
        "image/bmp" = "oculante.desktop";
        "image/gif" = "oculante.desktop";
        "image/jpg" = "oculante.desktop";
        "image/pjpeg" = "oculante.desktop";
        "image/png" = "oculante.desktop";
        "image/tiff" = "oculante.desktop";
        "image/webp" = "oculante.desktop";
        "image/x-bmp" = "oculante.desktop";
        "image/x-gray" = "oculante.desktop";
        "image/x-icb" = "oculante.desktop";
        "image/x-ico" = "oculante.desktop";
        "image/x-png" = "oculante.desktop";
        "image/x-portable-anymap" = "oculante.desktop";
        "image/x-portable-bitmap" = "oculante.desktop";
        "image/x-portable-graymap" = "oculante.desktop";
        "image/x-portable-pixmap" = "oculante.desktop";
        "image/x-xbitmap" = "oculante.desktop";
        "image/x-xpixmap" = "oculante.desktop";
        "image/x-pcx" = "oculante.desktop";
        "image/svg+xml" = "oculante.desktop";
        "image/svg+xml-compressed" = "oculante.desktop";
        "image/vnd.wap.wbmp" = "oculante.desktop";
        "image/x-icns" = "oculante.desktop";
        "text/plain" = "com.system76.CosmicEdit.desktop";
        "application/pdf" = "org.pwmt.zathura.desktop";
        "x-scheme-handler/mailto" = "chromium.desktop";
        "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        "inode/directory" = "com.system76.CosmicFiles.desktop";
        # Writer (documents)
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice-writer.desktop";
        "application/msword" = "libreoffice-writer.desktop";
        "application/rtf" = "libreoffice-writer.desktop";
        "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
        # Impress (presentations)
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "libreoffice-impress.desktop";
        "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
        "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
        # Calc (spreadsheets)
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
        "application/vnd.ms-excel" = "libreoffice-calc.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
        "x-scheme-handler/sgnl" = "signal.desktop";
        "x-scheme-handler/signalcaptcha" = "signal.desktop";
      };
    };
  };

  # Deploy raw config files for apps with complex formats
  xdg.configFile = {
    "fastfetch/config.jsonc".source = ../raw/fastfetch/config.jsonc;
    "mpv/mpv.conf".source = ../raw/mpv/mpv.conf;
    "mpv/input.conf".source = ../raw/mpv/input.conf;
    "gdb/gdbinit".source = ../raw/gdb/gdbinit;
    "ranger/commands.py".source = ../raw/ranger/commands.py;
  };
}
