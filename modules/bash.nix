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
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.sessionVariables = {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };
      programs.starship.enable = true;
      programs.bash = {
        enable = true;
        historyFileSize = 1000000000;
        shellAliases = let
          eza = "${pkgs.eza}/bin/eza --color-scale=all";
        in {
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          ls = "${eza}";
          la = "${eza} -la";
          tree = "${eza} --tree";
        };
      };

      programs.autojump = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
