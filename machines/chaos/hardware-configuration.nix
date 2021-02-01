# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_testing;

  fileSystems."/" =
    { device = "pool/local/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "pool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CFFD-96A0";
      fsType = "vfat";
    };

  fileSystems."/cache" =
    { device = "pool/local/cache";
      fsType = "zfs";
    };

  fileSystems."/data" =
    { device = "pool/safe/data";
      fsType = "zfs";
    };

  swapDevices = [ ];
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  services.fstrim.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
