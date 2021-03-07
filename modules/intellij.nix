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
    custom.allowUnfree = [ pkgs.jetbrains.idea-ultimate ];
    home-manager.users.rien = let
      path = with pkgs; [ jdk python3 nodejs yarn nodePackages."@vue/cli" ];
      intellij = pkgs.runCommand "intellij" 
        { nativeBuildInputs = [ pkgs.makeWrapper ]; }
        ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.jetbrains.idea-ultimate}/bin/idea-ultimate \
            $out/bin/intellij \
            --prefix PATH : ${lib.makeBinPath path}
        '';
    in { ... }: {
      home.packages = [ intellij ];
    };
  };
}
