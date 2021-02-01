{ config, lib, pkgs, ... }:
{

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" "snd-bcm2835"];

  boot.kernelPackages = pkgs.linuxPackages_4_19;
  boot.kernelParams = ["cma=256M"];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    disable_overscan=1
    config_hdmi_boost=7
    dtoverlay=vc4-fkms-v3d
    dtparam=audio=on
    dtparam=i2c_arm=on
    dtparam=spi=on
    gpu_mem=256
    hdmi_drive=2
    hdmi_force_hotplug=1
  '';

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  environment.systemPackages = with pkgs; [
    libraspberrypi
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
