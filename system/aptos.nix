# Aptos — Microsoft's default Office font (since 2023).
#
# Not in nixpkgs: Microsoft's licence forbids redistribution, so there's no URL
# to fetch. `requireFile` covers this case — you supply the file yourself and
# Nix identifies it by hash rather than by path.
#
# That indirection is also necessary because the zip sits in third-party/, which
# is gitignored, and flakes only see git-tracked files.
#
# One-time setup (you should only need to do this once per machine):
#
#   # nix store paths can't contain spaces, so copy to a clean name:
#   cp 'third-party/Microsoft Aptos Fonts.zip' /tmp/aptos-fonts.zip
#   nix-store --add-fixed sha256 /tmp/aptos-fonts.zip
#   rm /tmp/aptos-fonts.zip
#
# After that, `sudo nixos-rebuild switch` builds normally. If you ever
# garbage-collect the store object, just re-run the three commands above.

{ stdenvNoCC, lib, requireFile, unzip }:

stdenvNoCC.mkDerivation {
  pname = "aptos-fonts";
  version = "2024-05-29";

  # `requireFile` returns a derivation pointing at the file once it's
  # been added to the store under exactly this name + sha256.
  src = requireFile {
    name = "aptos-fonts.zip";
    sha256 = "6528fd120e719a9f985e94214eca6887d1653b88456916a792a630b02e95b025";
    message = ''
      Aptos.zip is not in the Nix store yet. Run these three commands
      from the dotfiles repo root, then retry the rebuild:

        cp 'third-party/Microsoft Aptos Fonts.zip' /tmp/aptos-fonts.zip
        nix-store --add-fixed sha256 /tmp/aptos-fonts.zip
        rm /tmp/aptos-fonts.zip

      If you don't have the zip yet, see third-party/README.md for the
      download link.
    '';
  };

  # `unzip` is needed at build time because the source is a .zip.
  # `nativeBuildInputs` are tools that run on the build host.
  nativeBuildInputs = [ unzip ];

  # The Aptos zip extracts flat (no top-level directory), which trips up
  # stdenv's default unpack phase ("unpacker appears to have produced no
  # directories"). Skip it and unpack manually in installPhase instead.
  dontUnpack = true;
  dontBuild = true;

  # Install: unzip and drop every .ttf into the standard system font dir.
  # NixOS auto-discovers fonts under $out/share/fonts/.
  installPhase = ''
    runHook preInstall
    unzip $src
    install -Dm644 -t $out/share/fonts/truetype *.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Aptos — Microsoft's default Office sans-serif typeface";
    homepage = "https://learn.microsoft.com/en-us/typography/font-list/aptos";
    # Proprietary — included because the user owns it via Microsoft 365.
    # Don't redistribute the .zip outside this machine.
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
