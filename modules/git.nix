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
            init.defaultBranch = "main";
            url."ssh://git@github.com/".insteadOf = "https://github.com/";
            branch = {
              autosetuprebase = "always";
            };
            pull = {
              rebase = true;
            };
            core.autocrlf = "input";
          };
          ignores = [
            ".direnv"
            ".envrc"
            "shell.nix"
            # Ruby dependencies in source tree
            "/vendor/bundle"
            "**/*.patch"
            # IntelliJ
            ".idea/*"
            "*.iml"
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
      home-manager.users.${config.custom.user} = { ... }: base;
      home-manager.users.root = { ... }: base;
    };
}
