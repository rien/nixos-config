{ pkgs, ... }:
{
  # List of extra packages which should be installed
  environment.systemPackages = with pkgs; [
     wget vim git htop
  ];
}

