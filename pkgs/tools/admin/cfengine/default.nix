{ lib, stdenv, fetchurl, lmdb, openssl, bison, python, pcre, linux-pam, shadow }:

stdenv.mkDerivation rec {
  pname = "cfengine";
  version = "3.21.0";

  src = fetchurl {
    url = "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-community-3.21.0.tar.gz";
    sha256 = "sha256-kRd43bCk4Do938j8DwMxNuFVGEnqLcvbPw8UNZ3+MSY=";
  };


  buildInputs = [
    lmdb
    bison
    openssl
    linux-pam
    shadow
    pcre
  ];

  meta = with lib; {
    homepage = "https://cfengine.com";
    description = "Automate your infrastructure, security & compliance";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
