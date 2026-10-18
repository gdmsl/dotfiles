# Toshiba's CUPS driver for its black-and-white e-STUDIO copiers, which covers
# the e-STUDIO2528A in the CESQ office. nixpkgs has only the colour one
# (cups-toshiba-estudio).
#
# What it installs:
#   - a PPD, which tells CUPS what the copier can do: trays, duplex, stapling,
#     department codes. CUPS's generic PostScript PPD knows none of that.
#   - est856_Authentication, a small Perl filter that adds the user name and
#     job name to each job, so the copier can log and account it.
#
# The zip comes from Toshiba TEC Europe's driver page. Their download server
# doesn't send its full TLS certificate chain, so certificate checks are
# skipped. The pinned hash still guarantees the exact file: Nix rejects any
# download that doesn't match.

{ stdenvNoCC, lib, fetchurl, unzip, perl, nettools }:

stdenvNoCC.mkDerivation rec {
  pname = "cups-toshiba-estudio-mono";
  version = "7.119.4.0";

  src = fetchurl {
    name = "toshiba-estudio-cups-ppd-${version}.zip";
    url = "https://downloads.toshibatec.eu/publicsite-service/resource/download/pseu/en/c47a2f8b-f1fb-47cb-8a6b-6a758250916c/f44b2902712bb59bad54b674cf52ad96/TOSHIBA%20e-STUDIO%20CUPS%20PPD%20%5BV.${version}%5D.zip";
    hash = "sha256-bNxX/CVSJ5lCCv8BsuCYSKRe7TJybYy9qmshE5Yv8w0=";
    curlOptsList = [ "--insecure" ];
  };

  nativeBuildInputs = [ unzip ];
  buildInputs = [ perl ];  # so patchShebangs points the filter at Nix's perl

  # The zip holds mono and colour tars, each in a "normal" and a
  # "2-sided_default" flavour. Take the mono "normal" one; duplex can be made
  # the default per printer through ppdOptions. The tar's paths are absolute
  # (/usr/...), and tar strips the leading slash on extraction.
  unpackPhase = ''
    unzip -q $src
    tar xf */BW/normal/TOSHIBA_MonoMFP_CUPS.tar
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/lib/cups/filter/est856_Authentication -t $out/lib/cups/filter
    patchShebangs $out/lib/cups/filter
    # The filter calls `domainname`, which isn't on CUPS's PATH on NixOS.
    substituteInPlace $out/lib/cups/filter/est856_Authentication \
      --replace-fail '`domainname`' '`${nettools}/bin/domainname`'

    mkdir -p $out/share/cups/model/Toshiba
    zcat usr/share/cups/model/Toshiba/TOSHIBA_MonoMFP_CUPS.gz \
      | sed "s+/usr/lib/cups/filter+$out/lib/cups/filter+" \
      | gzip -n > $out/share/cups/model/Toshiba/TOSHIBA_MonoMFP_CUPS.gz

    runHook postInstall
  '';

  meta = {
    description = "CUPS driver for Toshiba black-and-white e-STUDIO copiers";
    homepage = "https://www.toshibatec.eu/support/drivers/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
