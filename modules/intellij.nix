{ config, lib, pkgs, ... }:
let
  cfg = config.custom.intellij;
in {
  options.custom.intellij = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config = lib.mkIf cfg.enable {
    config.custom.allowUnfree = with pkgs; [ jetbrains.idea-ultimate ];
    home-manager.users.rien = let
      paths = with pkgs; [
        jdk python3 nodejs yarn
      ];
      intellij = writeScriptBin "intellij" ''
        ${pkgs.jetbrains.idea-ultimate}
        '';
    in { pkgs, ... }: {
      home.packages = with pkgs; [
        jetbrains.idea-ultimate
      ];
    };
  };
}
