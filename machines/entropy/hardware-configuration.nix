{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "snd-seq" "snd-rawmidi" "snd-usb-audio" "btqca" "hci_uart" "joydev" ];
  boot.kernelParams = [ "mitigations=off" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = ''
     options snd-intel-dspcfg dsp_driver=1
  '';

  fileSystems."/" =
    { device = "pool/local/root";
    fsType = "zfs";
  };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F511-7963";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/nix" =
    { device = "pool/local/nix";
    fsType = "zfs";
  };

  services.fstrim.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  swapDevices = [ {
    device = "/dev/zvol/pool/swap";
  } ];

  hardware = {
    steam-hardware.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

}
