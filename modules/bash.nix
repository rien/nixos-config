{ config, lib, ... }:
with lib;
{
  options.custom.bash = {
    enable = mkOption {
      example = true;
      default = false;
    };
  };

  config = mkIf config.custom.bash.enable {
    home-manager.users.rien = { pkgs, ... }: {
      programs.bash = {
        enable = true;
        shellAliases = let
          exa = "${pkgs.exa}/bin/exa --colour-scale";
        in {
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          ls = "${exa}";
          la = "${exa} -la";
          tree = "${exa} --tree";
        };
      };

      programs.autojump = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
