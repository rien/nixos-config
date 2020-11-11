{ config, lib, pkgs, ... }:
{

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel= 7;
  boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835"];

  boot.kernelParams = ["cma=256M"];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
      hdmi_drive=2
      hdmi_force_hotplug=1
      config_hdmi_boost=11
      gpu_mem=256
      dtparam=audio=on
  '';

  hardware.pulseaudio.enable = true;

  environment.systemPackages = with pkgs; [
    raspberrypi-tools
  ];

  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];


  nix.maxJobs = lib.mkDefault 2;
}
