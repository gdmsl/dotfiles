# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  neovide.nix — Neovide, a GPU-accelerated GUI for Neovim                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Neovide is a native window that embeds Neovim instead of drawing it inside a
# terminal. It speaks Neovim's msgpack API and renders with Skia on the GPU,
# which is what buys the smooth cursor and scroll animations.
#
# The configuration comes in two halves, and they live in different places:
#
#   * Window and process settings — font, decorations, which nvim binary to
#     launch — are Neovide's own. They go in ~/.config/neovide/config.toml,
#     which Home Manager renders from the `settings` attrset below.
#
#   * Behaviour settings — animations, transparency — are Neovim global
#     variables, so they belong in Neovim's Lua config. They're in neovim.nix,
#     wrapped in `if vim.g.neovide`, because that variable exists only when
#     Neovide is the UI attached to Neovim.
#
# Option reference: https://neovide.dev/config-file.html

{ config, ... }:

{
  programs.neovide = {
    enable = true;

    settings = {
      # Which Neovim to launch. Left unset, Neovide runs whatever `nvim`
      # resolves to on PATH — and an app started by the compositor doesn't
      # necessarily inherit the PATH a login shell has. `finalPackage` is the
      # wrapped Neovim nvf builds out of neovim.nix, so this always points at
      # the editor this repo configures, plugins and all.
      neovim-bin = "${config.programs.nvf.finalPackage}/bin/nvim";

      # Detach from the shell that launched it, so `neovide file.txt` gives the
      # prompt straight back instead of tying up the terminal until you quit.
      fork = true;

      frame = "full";   # normal window decorations
      theme = "auto";   # follow the system light/dark preference
      vsync = true;     # sync to the display refresh rate, avoids tearing

      # ── Font ──────────────────────────────────────────────────────────────
      # Neovide rasterises text itself rather than going through a terminal, so
      # it needs its own font settings. These mirror kitty.nix so that the same
      # file looks identical in either one.
      font = {
        normal = [ "FiraCode Nerd Font Mono" ];
        italic = [ "Maple Mono" ];
        bold_italic = [ "Maple Mono" ];
        size = 12.0;
      };
    };
  };
}
