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

{ config, pkgs, ... }:

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

  # ── PassFF native messaging host ──────────────────────────────────────────
  # The PassFF browser extension can't call `pass` on its own — extensions run
  # sandboxed. Instead it speaks to a "native messaging host": a small Python
  # script (passff.py) described by a JSON manifest. Firefox finds that manifest
  # by looking for ~/.mozilla/native-messaging-hosts/<name>.json.
  #
  # The passff-host package ships both the script and the manifest, and the
  # manifest already embeds the absolute /nix/store path to passff.py. We just
  # symlink the manifest into the place Firefox searches. Referencing the store
  # path here pulls passff-host into this profile's closure, so there's nothing
  # to add to home.packages. This lookup path is fixed by Firefox and shared by
  # every profile, so it serves both the default and the ~/Personal launcher.
  home.file.".mozilla/native-messaging-hosts/passff.json".source =
    "${pkgs.passff-host}/lib/mozilla/native-messaging-hosts/passff.json";
}
