# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  ciel.nix — the ciel assistant orb, with its data in ~/Personal             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# ciel comes from its own private flake (the `ciel` input), whose Home Manager
# module runs the `cield` daemon as a user service. Keybindings are in
# raw/niri/config.kdl and raw/hypr/conf/keybindings.lua (Mod+Alt+…).
#
# ciel keeps transcripts, enrolled voices, settings and API keys in
# ~/.local/share/ciel and ~/.config/ciel. Both are links into ~/Personal, like
# Telegram's and Discord's in default.nix, so all of it stays encrypted and the
# daemon and the `ciel` command still find it at the usual paths. The speech
# models (about 2 GB, downloaded again if missing) stay outside, in ~/.cache.
#
# Because of that, cield only runs while ~/Personal is mounted: it starts when
# the vault is unlocked and stops when it's locked.

{ config, pkgs, lib, inputs, ... }:

let
  home = config.home.homeDirectory;
  link = path: config.lib.file.mkOutOfStoreSymlink "${home}/Personal/${path}";
  # systemd's name for the vault mount, e.g. home-gdmsl-Personal.mount.
  vaultMount = "${lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" home)}-Personal.mount";
in
{
  imports = [ inputs.ciel.homeModules.default ];

  services.ciel.enable = true;

  home.file = {
    ".local/share/ciel".source = link ".local/share/ciel";
    ".config/ciel".source = link ".config/ciel";

    # Starts `ciel transcribe` in the background, or stops the running one,
    # on one key (Mod+Alt+R). SIGINT is what Ctrl-C sends, so ciel finishes
    # the same way as in a terminal. ciel keeps the transcript itself;
    # `ciel transcripts` lists them.
    ".local/bin/ciel-transcribe-toggle" = {
      executable = true;
      text = ''
        #!/bin/sh
        if ${pkgs.procps}/bin/pkill -INT -f 'bin/ciel transcribe'; then
          ${pkgs.libnotify}/bin/notify-send -a ciel "Transcription stopped" "'ciel transcripts' lists it."
        else
          ${pkgs.libnotify}/bin/notify-send -a ciel "Transcribing" "Mod+Alt+R again to stop."
          exec ciel transcribe >/dev/null 2>&1
        fi
      '';
    };
  };

  systemd.user.services.cield = {
    Unit = {
      # Stop with the vault: once it's unmounted the links point nowhere.
      BindsTo = [ vaultMount ];
      After = [ vaultMount ];
    };
    Service = {
      Environment = "CIEL_MODELS=${config.xdg.cacheHome}/ciel/models";
      # The links' targets don't exist on a fresh vault.
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Personal/.local/share/ciel %h/Personal/.config/ciel";
    };
    # Start on unlock instead of at login, when the vault is usually locked.
    Install.WantedBy = lib.mkForce [ vaultMount ];
  };
}
