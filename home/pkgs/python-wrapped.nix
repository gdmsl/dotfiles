# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  pkgs/python-wrapped.nix — Python that can load pip wheels on NixOS         ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Wheels from PyPI (numpy, scipy, …) link against libstdc++ and friends at
# standard FHS paths, which don't exist on NixOS, so importing one fails with
# "libstdc++.so.6: cannot open shared object file". This wraps `python3` so
# those libraries are on LD_LIBRARY_PATH.
#
# A venv made with this python (`python3 -m venv`, or `uv venv` with uv
# finding it on PATH) symlinks to the wrapper, so the venv's scripts get the
# fix too. Venvs made before switching to this wrapper need recreating.
#
# Add another entry to the list below if a wheel fails to dlopen something.
#
#   (import ./pkgs/python-wrapped.nix { inherit pkgs; })

{ pkgs }:

pkgs.python3.buildEnv.override {
  makeWrapperArgs = [
    "--suffix" "LD_LIBRARY_PATH" ":"
    (pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib  # libstdc++
      pkgs.zlib
    ])
  ];
}
