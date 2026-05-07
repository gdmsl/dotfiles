# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  pkgs/julia-wrapped.nix — Julia with FHS-style libdirs for JLL artifacts   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Julia's package manager downloads prebuilt JLL artifacts that expect
# FHS-standard library paths. On NixOS those paths don't exist, so dlopen
# fails (e.g. libquadmath.so.0 not found when loading OpenSpecFun_jll).
# symlinkJoin + wrapProgram produces a `julia` whose every invocation gets
# these libs appended to LD_LIBRARY_PATH.
#
# Usage: `(import ./pkgs/julia-wrapped.nix { inherit pkgs; })` inside a
# `home.packages = with pkgs; [ ... ]` list.

{ pkgs }:

pkgs.symlinkJoin {
  name = "julia-wrapped";
  paths = [ pkgs.julia ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/julia \
      --suffix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
        pkgs.gcc-unwrapped.lib   # libquadmath, libgfortran, libgcc_s
        pkgs.stdenv.cc.cc.lib    # libstdc++
        pkgs.zlib
        pkgs.glibc
      ]}
  '';
}
