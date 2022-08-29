{ config, lib, pkgs, custompkgs, ... }:
let
  cfg = config.custom.intellij;
in {
  options.custom.vscode = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${config.custom.user} = { ... }: {
      programs.vscode = {
        enable = true;
        #package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          github.copilot
        ];
      };
    };
  };
}
