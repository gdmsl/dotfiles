# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  pkgs/ant.nix — Anthropic's `ant` CLI for the Claude API                   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Not in nixpkgs (there `ant` is Apache Ant), so this installs the static Go
# binary from the GitHub release. To update, bump `version` and take the
# linux_amd64 hash from that release's ant_<version>_checksums.txt.
#
#   pkgs.callPackage ./pkgs/ant.nix { }

{ stdenvNoCC, fetchurl, installShellFiles, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "anthropic-cli";
  version = "2.9.0";

  src = fetchurl {
    url = "https://github.com/anthropics/anthropic-cli/releases/download/v${version}/ant_${version}_linux_amd64.tar.gz";
    hash = "sha256-aRWPahfpLo5VngBhvqJTCsW2CXb7bWl2cxNtEQ6+NR8=";
  };

  # The tarball has no top-level directory.
  sourceRoot = ".";
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    install -Dm755 ant $out/bin/ant
    installManPage man/man1/ant.1.gz
    installShellCompletion completions/ant.{bash,fish,zsh}
  '';

  meta = {
    description = "Command-line client for the Claude API";
    homepage = "https://github.com/anthropics/anthropic-cli";
    license = with lib.licenses; [ asl20 mit ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ant";
  };
}
