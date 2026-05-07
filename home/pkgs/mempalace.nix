# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  pkgs/mempalace.nix — mempalace package definition                         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Local-first AI memory system (https://github.com/mempalace/mempalace). Not in
# nixpkgs, so we build it ourselves from PyPI. Extracted into its own file so
# multiple home-manager profiles (full desktop + headless tty) can pull in the
# same package without duplicating the build recipe.
#
# Usage: callers do `import ./pkgs/mempalace.nix { inherit pkgs lib; }` and
# stick the result into `home.packages`.

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
