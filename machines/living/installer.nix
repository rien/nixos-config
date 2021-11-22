{ config, pkgs, lib, ... }:
let
  personal = import ../../modules/personal.secret.nix;
in {

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-installer.nix>
  ];

  # Do not compress the image as we want to use it straight away
  sdImage.compressImage = false;

  documentation.enable = false;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  services.openssh = {
    enable = true;
    ports = [ 9450 ];
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  users.users.root = {
    openssh.authorizedKeys.keys = with personal.sshKeys; [ chaos ];
  };
}

