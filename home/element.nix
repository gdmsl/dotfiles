# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  element.nix — Element (Matrix), pointed at the real keyring                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Plain `pkgs.element-desktop` starts up complaining:
#
#     Your system has an unsupported keyring
#
# Nothing is wrong with the keyring. gnome-keyring is running and answering on
# org.freedesktop.secrets (system/default.nix turns it on and hooks it into PAM,
# so logging in unlocks it). Element simply never looks there.
#
# Element is an Electron app, and Electron encrypts its secrets through
# Chromium's safeStorage. On Linux, Chromium decides which backend to use by
# *sniffing the desktop environment* — it reads XDG_CURRENT_DESKTOP and maps
# GNOME-ish values to libsecret and KDE-ish ones to KWallet. Here that variable
# says `niri`, which matches neither, so Chromium falls back to the `basic`
# backend: a hardcoded key, i.e. secrets sitting in plaintext on disk. Element
# 1.12 refuses to run that way, and the message above is how it says so.
#
# The override for the guess is the --password-store flag, and it has to be
# baked into the binary: ~/.config/electron-flags.conf (linked in
# home/default.nix) is a convention of *launcher scripts* — Chromium's own, and
# the ones Arch wraps Electron apps in. The nixpkgs wrapper doesn't read it; it
# execs electron with the app bundle directly.

{ pkgs, ... }:

let
  # Chromium's name for the libsecret backend — that is, gnome-keyring reached
  # over the org.freedesktop.secrets D-Bus API. The other values it accepts are
  # `kwallet`, `kwallet5`, `kwallet6` and `basic`.
  passwordStore = "gnome-libsecret";

  # symlinkJoin re-exports an existing package as a tree of symlinks, then lets
  # postBuild edit that tree. The point is what it *doesn't* do: element-desktop
  # is not rebuilt, so the binary cache still supplies it. (Reaching for
  # overrideAttrs to touch the wrapper would instead rebuild the whole thing
  # from source, yarn deps and all.)
  element = pkgs.symlinkJoin {
    name = "element-desktop-${pkgs.element-desktop.version}";
    paths = [ pkgs.element-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    # wrapProgram moves bin/element-desktop aside to .element-desktop-wrapped
    # (here that's a symlink into the original store path, which is all we want
    # to keep) and writes a small script in its place that re-execs it with the
    # flag appended.
    #
    # The desktop entry that ships with the package says `Exec=element-desktop`
    # with no path, so launchers resolve it through PATH and get this wrapper —
    # no second .desktop file needed.
    postBuild = ''
      wrapProgram $out/bin/element-desktop \
        --add-flags "--password-store=${passwordStore}"
    '';
  };
in
{
  home.packages = [ element ];
}
