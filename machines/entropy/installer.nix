# Usage:
# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./installer.nix \
#  --argstr system aarch64-linux \
#  --option sandbox false
{ config, pkgs, lib, ... }:
let
  personal = import ../../modules/personal.secret.nix;
in {

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix>
  ];

  # Do not compress the image as we want to use it straight away
  sdImage.compressImage = false;

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


  networking.wireless = {
    enable = true;
    networks = import ../../modules/wireless/networks.secret.nix;
    interfaces = [ "wlan0" ];
    userControlled.enable = true;
  };

  networking.interfaces."wlan0".useDHCP = true;

  networking.hostName = "entropy";
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.dhcpcd.extraConfig = ''
    interface eth0
    inform 192.168.0.2

    interface wlan0
    inform 192.168.0.3
  '';

  users.users.root = {
    openssh.authorizedKeys.keys = with personal.sshKeys; [ chaos ];
  };
}

