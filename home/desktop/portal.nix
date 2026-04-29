# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  portal.nix — XDG Desktop Portal backends (user-profile side)              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# The system module already enables xdg.portal at the NixOS level, but Home
# Manager runs its own copy of the xdg-desktop-portal user service. HM sets
# NIX_XDG_DESKTOP_PORTAL_DIR to the *user* profile path, so the running
# portal only loads .portal files installed under
# /etc/profiles/per-user/$USER/share/xdg-desktop-portal/portals/. That path
# is HM-managed — system-level extraPortals never land there.
#
# `wayland.windowManager.hyprland.enable` already adds the Hyprland portal
# at the HM level. Niri has no portal of its own; on Niri,
# xdg-desktop-portal-gnome is the bridge between the portal API and Niri's
# `org.gnome.Mutter.ScreenCast` D-Bus service (Niri implements the Mutter
# screencast interface), which is what Firefox/Edge actually call into.
# `xdg-desktop-portal-gtk` covers FileChooser and other non-screencast bits.
#
# The `config.<desktop>.default` keys are matched against
# $XDG_CURRENT_DESKTOP, which the niri and hyprland sessions set
# automatically.

{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # xdg-desktop-portal-hyprland is also pulled in by the HM Hyprland
      # module — listing it here makes the intent explicit and is harmless.
      xdg-desktop-portal-hyprland
    ];
    config = {
      common.default = [ "gtk" ];
      niri.default = [ "gnome" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };
}
