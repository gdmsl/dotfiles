# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  pkgs/julia-wrapped.nix — Julia with FHS-style libdirs for JLL artifacts   ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Julia downloads prebuilt JLL artifacts that expect libraries at standard FHS
# paths, which don't exist on NixOS — so loading one fails with something like
# "libquadmath.so.0 not found". This wraps `julia` so those libraries are on
# LD_LIBRARY_PATH.
#
# Add another entry to the list below if a package fails to dlopen something.
#
#   (import ./pkgs/julia-wrapped.nix { inherit pkgs; })

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
