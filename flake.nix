# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  flake.nix — The entry point of this entire configuration                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# A "flake" is Nix's way of defining a reproducible project. Think of it like
# a package.json or Cargo.toml but for your entire system. It has two parts:
#
#   inputs  — External dependencies (other flakes, repos, packages).
#   outputs — What this flake produces (a NixOS system, a Home Manager config).
#
# The flake.lock file (auto-generated) pins every input to an exact commit,
# so builds are reproducible: same inputs → same result, every time.
#
# Quick reference:
#   sudo nixos-rebuild switch --flake .#yara    — rebuild the full NixOS system
#   home-manager switch --flake .#gdmsl         — rebuild just the user environment
#   nix flake update                            — update all inputs to latest
{
  description = "gdmsl - yara NixOS system + Home Manager user config";

  # ── Inputs ────────────────────────────────────────────────────────────────
  # Each input is a dependency fetched from a URL (usually a GitHub flake).
  # "follows" means "use the same nixpkgs that I declared above" — this avoids
  # downloading multiple copies of nixpkgs and keeps everything consistent.
  inputs = {
    # The main Nix package repository. "nixos-unstable" is the rolling-release
    # channel with the latest packages (as opposed to stable release branches).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Hardware-specific tweaks (kernel params, firmware, power) for well-known
    # laptop/desktop models. Provides a NixOS module for our ThinkPad.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Home Manager: manages dotfiles and user-level programs declaratively.
    # `inputs.nixpkgs.follows = "nixpkgs"` ensures it uses our nixpkgs above.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Third-party flakes for desktop utilities
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
    };

    anyrun = {
      url = "github:anyrun-org/anyrun";
      # Don't override nixpkgs — breaks their binary cache
    };

    # nvf (Neovim Flake): a framework for configuring Neovim entirely in Nix,
    # without writing Lua files by hand.
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ── Outputs ───────────────────────────────────────────────────────────────
  # The output function receives all resolved inputs and produces the actual
  # configurations. The `@inputs` syntax captures all inputs into one attrset
  # so we can pass them to modules that need them (e.g., nvf, vicinae).
  outputs = { nixpkgs, nixos-hardware, home-manager, noctalia, ... }@inputs:
    let
      system = "x86_64-linux";

      # `legacyPackages` gives us the full nixpkgs package set for our platform.
      pkgs = nixpkgs.legacyPackages.${system};

      # Absolute path to this repo on disk. Used by mkOutOfStoreSymlink to
      # create live symlinks (so changes to raw/ files take effect without
      # rebuilding). Change this if you clone the repo elsewhere.
      dotfilesPath = "/home/gdmsl/dotfiles";
    in {
      # ── NixOS system configuration ──────────────────────────────────────
      # This defines the *entire operating system*: kernel, services, users,
      # system packages, boot loader, etc.
      # Usage: sudo nixos-rebuild switch --flake .#yara
      nixosConfigurations.yara = nixpkgs.lib.nixosSystem {
        inherit system;
        # `specialArgs` passes extra arguments to every NixOS module so they
        # can access our flake inputs.
        specialArgs = { inherit inputs; };
        modules = [
          # Hardware-specific NixOS module for this exact laptop model
          nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
          # Our system configuration (see system/default.nix)
          ./system
          # Integrate Home Manager as a NixOS module — this means the user
          # environment is rebuilt together with the system in one command.
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;         # share the system's nixpkgs
            home-manager.useUserPackages = true;        # install user pkgs to /etc/profiles
            home-manager.backupFileExtension = "hm-backup"; # back up conflicting files
            home-manager.extraSpecialArgs = { inherit inputs dotfilesPath; };
            home-manager.users.gdmsl = import ./home;  # user config entry point
          }
        ];
      };

      # ── Standalone Home Manager ─────────────────────────────────────────
      # For use on machines where you don't control the NixOS system config
      # (e.g., a work server with Nix installed on Ubuntu).
      # Usage: home-manager switch --flake .#gdmsl
      homeConfigurations."gdmsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs dotfilesPath; };
        modules = [ ./home ];
      };
    };
}
