# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  pkgs/mempalace.nix — mempalace package definition                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Not in nixpkgs, so it's built from PyPI here. In its own file so both the
# desktop and headless profiles get the same derivation.
#
#   import ./pkgs/mempalace.nix { inherit pkgs lib; }

{ pkgs, lib }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "mempalace";
  version = "3.3.3";
  pyproject = true;  # tells nix the project uses pyproject.toml + PEP 517

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-ttMVcabQIb7kKOQBmO61xXQohfsXLSSDvbtjoaFFhIc=";
  };

  # hatchling is the build backend declared in mempalace's pyproject.toml.
  build-system = [ pkgs.python3Packages.hatchling ];

  # Runtime dependencies. tomli is only needed on Python <3.11, and our
  # pkgs.python3 is newer than that, so we can skip it.
  dependencies = with pkgs.python3Packages; [
    chromadb
    pyyaml
  ];

  # Sanity-check the build by importing the top-level module.
  pythonImportsCheck = [ "mempalace" ];

  meta = {
    description = "Local-first AI memory system with semantic search";
    homepage = "https://github.com/mempalace/mempalace";
    license = lib.licenses.mit;
    mainProgram = "mempalace";
  };
}
