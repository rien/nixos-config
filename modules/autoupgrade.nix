{ config, lib, self, ... }:
with lib;
{
  options.custom.autoupgrade = {
    enable = mkOption {
      example = true;
      default = false;
    };
    allowReboot = mkOption {
      example = true;
      default = false;
    };
  };

  config = mkIf config.custom.autoupgrade.enable {
    system.autoUpgrade = {
      enable = true;
      flake = self.outPath;
      flags = [
        "--update-input" "nixpkgs"
        "--no-write-lock-file"
        "-L"
      ];
      dates = "02:20";
      fixedRandomDelay = true;
      allowReboot = config.custom.autoupgrade.allowReboot;
    };
  };
}
