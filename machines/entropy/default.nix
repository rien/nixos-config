{ config, pkgs, ... }:
let
  secret = import ./secret.nix;
in
{
  imports =
    [
      ./motd.nix
      ./hardware-configuration.nix
    ];


  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;
    nginx.enable = true;

    extraSystemPackages = with pkgs; [
      htop
    ];

    wireless = {
      enable = true;
      device = "wlan0";
    };
  };

  networking.hostName = "entropy";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.11";
}

