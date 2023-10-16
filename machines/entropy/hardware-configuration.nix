{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  console.enable = false;

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypifw
    raspberrypi-eeprom
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
