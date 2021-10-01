{ lib, stdenv, fetchFromGitHub, makeWrapper, autoconf, automake, cyrus_sasl, libtool, ... }:
stdenv.mkDerivation rec {
  pname = "cyrus_sasl_xoauth2";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "moriyoshi";
    repo = "cyrus-sasl-xoauth2";
    rev = "v0.2";
    sha256 = "sha256-lI8uKtVxrziQ8q/Ss+QTgg1xTObZUTAzjL3MYmtwyd8=";
  };

  nativeBuildInputs = [ makeWrapper autoconf automake libtool ];
  buildInputs = [ cyrus_sasl ];


  preConfigure = ''
    sed -i "s#CYRUS_SASL_PREFIX=/usr#CYRUS_SASL_PREFIX=$out#" configure.ac
    sed -i "s#CYRUS_SASL_PREFIXES=/usr#CYRUS_SASL_PREFIXES=$out#" configure.ac
    ./autogen.sh
  '';

}

