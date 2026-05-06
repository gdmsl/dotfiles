# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  noctalia.nix — Noctalia desktop shell                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Noctalia is a desktop shell (panel, system tray, notification daemon, etc.)
# that comes from a third-party flake. It provides its own Home Manager module
# which we import to get its `programs.noctalia-shell` options.
#
# `inputs.noctalia` is the flake input defined in flake.nix, and
# `homeModules.default` is the Home Manager module it exports.
#
# Plugins
# -------
# Noctalia has its own plugin system. Plugins are QML packages fetched at
# runtime from a "source" repository (defaults to the official noctalia-plugins
# repo on GitHub). The HM module lets us declare plugin state and per-plugin
# settings declaratively:
#
#   plugins        → ~/.config/noctalia/plugins.json   (which sources & which
#                                                        plugins are enabled)
#   pluginSettings → ~/.config/noctalia/plugins/<id>/settings.json
#                                                       (each plugin's settings)
#
# When a plugin is listed as enabled but missing on disk, Noctalia auto-fetches
# it from its source URL on next start — so just declaring it here is enough,
# no GUI install step needed. The downloaded plugin code itself is *not* in the
# Nix store; it lands in $XDG_CONFIG_HOME/noctalia/plugins/<id>/.

{ inputs, pkgs, ... }:

let
  noctaliaPluginsSource = "https://github.com/noctalia-dev/noctalia-plugins";
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      # Noctalia configuration — customize via the GUI or add settings here
    };

    # ── Plugins ──────────────────────────────────────────────────────────────
    # `version = 2` is the schema version of plugins.json (not a noctalia
    # version). `sources` lists the plugin repos to fetch from. `states.<id>`
    # marks individual plugins as enabled — Noctalia downloads them on demand.
    plugins = {
      version = 2;
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = noctaliaPluginsSource;
        }
      ];
      states = {
        # Hardware-accelerated screen recorder. Backed by gpu-screen-recorder
        # (installed in home/packages.nix) — the plugin shells out to it.
        # Uses xdg-desktop-portal for region/window selection by default.
        "screen-recorder" = {
          enabled = true;
          sourceUrl = noctaliaPluginsSource;
        };
        # Tailscale status, peer list, and Taildrop file send/receive in the
        # bar. Talks to the system `tailscale` CLI (already installed via
        # `services.tailscale.enable` + `tailscale` in system packages).
        tailscale = {
          enabled = true;
          sourceUrl = noctaliaPluginsSource;
        };
      };
    };

    # Per-plugin overrides. Anything left out falls back to the plugin's own
    # `defaultSettings` from its manifest.json.
    pluginSettings = {
      # screen-recorder = { directory = "${config.home.homeDirectory}/Videos"; };
      # tailscale = { taildropDownloadDir = "~/Downloads"; };
    };
  };
}
