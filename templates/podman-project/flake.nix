# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  flake.nix — Per-project Podman dev shell (template)                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Instantiated by `nix flake init -t /home/gdmsl/dotfiles#podman-project`.
# Provides `pc-up`, `pc-down`, `pc-logs`, `pc-ps` on $PATH inside the shell.
#
# After running `nix flake init -t ...`:
#   1. Edit the `description` below to match your project.
#   2. Edit `compose.yaml` to declare your real services.
#   3. `direnv allow` to authorize the .envrc.
#   4. `pc-up` to start the stack.
{
  description = "PROJECT-NAME — local development shell (podman-compose wrapper)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Bash aliases set inside `shellHook` don't survive direnv's env capture
      # — direnv exports environment variables back to fish, but aliases are
      # local to the bash subshell that ran the hook. To get real `pc-*`
      # commands on $PATH we build tiny wrapper scripts as actual binaries
      # in the Nix store. `writeShellScriptBin` is the helper for that.
      mkPc = name: subcommand: pkgs.writeShellScriptBin name ''
        exec ${pkgs.podman-compose}/bin/podman-compose ${subcommand} "$@"
      '';
      pcUp   = mkPc "pc-up"   "up -d";
      pcDown = mkPc "pc-down" "down";
      pcLogs = mkPc "pc-logs" "logs -f";
      pcPs   = mkPc "pc-ps"   "ps";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.podman-compose
          pcUp pcDown pcLogs pcPs
          # Add language toolchains / project-specific binaries here, e.g.:
          #   pkgs.nodejs_22
          #   pkgs.python3
          #   pkgs.go
        ];

        shellHook = ''
          echo "devShell loaded — pc-up | pc-down | pc-logs | pc-ps"
        '';
      };
    };
}
