{ config, lib, pkgs, ... }:
{
  options.custom.git = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config =
    let
      personal = import ./personal.secret.nix;
      base = {
        home.packages = with pkgs; [
          git-crypt
        ];
        programs.git = {
          enable = true;
          extraConfig = {
            branch = {
              autosetuprebase = "always";
            };
            pull = {
              rebase = true;
            };
          };
          ignores = [
            ".direnv"
            ".envrc"
            "shell.nix"
            # Ruby dependencies in source tree
            "/vendor/bundle"
            "**/*.patch"
          ];
          signing = {
            key = personal.email;
            signByDefault = true;
          };
          userEmail = personal.email;
          userName = "Rien Maertens";
        };
      };
    in
    lib.mkIf config.custom.git.enable {
      home-manager.users.rien = { ... }: base;
      home-manager.users.root = { ... }: base;
    };
}
