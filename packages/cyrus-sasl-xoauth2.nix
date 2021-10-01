{ lib, stdenv, fetchFromGitHub, ... }:
stdenv.makeDerivation rec {
  pname = "cyrus_sasl_xoauth2";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "moriyoshi";
    repo = "cyrus-sasl-xoauth2";
    rev = "v0.2";
  };

}

