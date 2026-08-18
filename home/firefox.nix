# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  firefox.nix — Firefox Personal profile desktop entry                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# A launcher entry that starts Firefox on a profile kept inside ~/Personal, so
# personal bookmarks, cookies and history stay encrypted at rest. The normal
# Firefox entry is untouched.
#
# `xdg.desktopEntries` writes to ~/.local/share/applications, which is where
# launchers look.

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
  # Browser extensions are sandboxed and can't run `pass` directly. They talk to
  # a helper script instead, which Firefox finds through a JSON manifest in
  # ~/.mozilla/native-messaging-hosts/.
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
