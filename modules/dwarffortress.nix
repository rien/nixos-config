{ config, lib, pkgs, ... }:
{
  options.custom.dwarffortress = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config = lib.mkIf config.custom.dwarffortress.enable {
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.packages = with pkgs.dwarf-fortress-packages; [
        dwarf-fortress-full
      ];
    };
  };
}
