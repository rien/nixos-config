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

        home.file.".config/git/allowed_signers".text = ''
          ${personal.email} namespaces="git" ${personal.sshKeys.chaos}
        '';

        programs.git = {
          enable = true;
          userEmail = personal.email;
          userName = "Rien Maertens";
          extraConfig = {
            init.defaultBranch = "main";
            branch.autosetuprebase = "always";
            pull.rebase = true;
            rebase.autoStash = true;
            push.autoSetupRemote = true;
            core.autocrlf = "input";
            diff.external = "${pkgs.difftastic}/bin/difft";
            user.signingkey = personal.sshKeys.chaos;
            commit.gpgsign = true;
            gpg = {
              format = "ssh";
              ssh = {
                allowedSignersFile = "~/.config/git/allowed_signers";
                program = "${pkgs._1password-gui}/bin/op-ssh-sign";
              };
            };
          };
          ignores = [
            ".data/"
            ".direnv"
            ".envrc"
            "shell.nix"
            # Ruby dependencies in source tree
            "/vendor/bundle"
            "**/*.patch"
            # IntelliJ
            ".idea/*"
            "*.iml"
            # Python
            "__pycache__"
            "venv"
            # syncthing
            ".stversions"
          ];
        };
      };
    in
    lib.mkIf config.custom.git.enable {
      home-manager.users.${config.custom.user} = { ... }: base;
      home-manager.users.root = { ... }: base;
    };
}
