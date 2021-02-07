{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  #boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" "snd-bcm2835"];

  #boot.initrd.includeDefaultModules = false;
  #boot.kernelPackages = pkgs.linuxPackages_rpi3;
  #boot.kernelParams = [];

  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" "10.0.0.0/24" ];
  networking.firewall.allowedTCPPorts = [ 4713 ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypifw
  ];

  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  nix.maxJobs = lib.mkDefault 1;
}
