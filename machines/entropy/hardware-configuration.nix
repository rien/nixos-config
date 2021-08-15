{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypifw
  ];

  hardware.enableRedistributableFirmware = true;
  #hardware.raspberry-pi."4".fkms-3d.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  nix.maxJobs = lib.mkDefault 4;
}
