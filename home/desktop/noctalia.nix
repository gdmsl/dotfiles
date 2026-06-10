# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  noctalia.nix — Noctalia desktop shell                                     ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Noctalia is a desktop shell (panel, system tray, notification daemon, etc.)
# that comes from a third-party flake. It provides its own Home Manager module
# which we import to get its `programs.noctalia` options.
#
# `inputs.noctalia` is the flake input defined in flake.nix, and
# `homeModules.default` is the Home Manager module it exports. That module also
# sets `programs.noctalia.package` for us by default, so we don't pick a package
# here.
#
# Settings
# --------
# `settings` is written to ~/.config/noctalia/config.toml. It accepts a Nix
# attrset (converted to TOML), a raw TOML string, or a path to a .toml file.
# Anything set here can still be changed at runtime from the settings menu.
# See <https://docs.noctalia.dev/v5> for the available keys.

{ inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    settings = {
      # Noctalia configuration — customize via the GUI or add settings here
    };
  };
}
