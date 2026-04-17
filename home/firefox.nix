# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  firefox.nix — Firefox Personal profile desktop entry                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Creates a custom .desktop launcher that opens Firefox with a specific
# profile stored inside the encrypted ~/Personal vault. This keeps personal
# browsing data (bookmarks, cookies, history) encrypted at rest.
#
# `xdg.desktopEntries` creates .desktop files in
# ~/.local/share/applications/ — these show up in app launchers.

{ config, ... }:

{
  xdg.desktopEntries.firefox-personal = {
    name = "Firefox Personal";
    genericName = "Web Browser";
    comment = "Personal Firefox profile (data in ~/Personal)";
    exec = "firefox --profile ${config.home.homeDirectory}/Personal/.mozilla/firefox/personal %u";
    icon = "firefox";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
