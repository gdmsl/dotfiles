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
