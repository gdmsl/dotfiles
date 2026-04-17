{
  description = "gdmsl - yara NixOS system + Home Manager user config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-hardware, home-manager, noctalia, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Absolute path to the dotfiles checkout (used for mkOutOfStoreSymlink).
      # Override with --override-input or by editing this line if the repo
      # lives somewhere other than ~/dotfiles.
      dotfilesPath = "/home/gdmsl/dotfiles";
    in {
      # NixOS system configuration
      # Usage: sudo nixos-rebuild switch --flake .#yara
      nixosConfigurations.yara = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
          ./system
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit inputs dotfilesPath; };
            home-manager.users.gdmsl = import ./home;
          }
        ];
      };

      # Standalone Home Manager (for use on non-NixOS or other machines)
      # Usage: home-manager switch --flake .#gdmsl
      homeConfigurations."gdmsl" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs dotfilesPath; };
        modules = [ ./home ];
      };
    };
}
