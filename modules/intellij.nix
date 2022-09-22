{ config, lib, pkgs, custompkgs, ... }:
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
    home-manager.users.${config.custom.user} = let
      overrideWithGApps = (pkg: pkg.overrideAttrs (oldAttrs: {nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.wrapGAppsHook ];}));
      devSDKs = with pkgs; {
        rustc = symlinkJoin { name = rustc.pname; paths = [ rustc cargo gcc ]; };
        rust-src =  rust.packages.stable.rustPlatform.rustLibSrc;
        java11 = jdk11;
        java17 = jdk17;
        ruby_3_0 = ruby_3_0;
        ruby_3_1 = ruby_3_1;
        openjfx = openjfx;
        scenebuilder = scenebuilder;
        python = python3;
        node = nodejs;
        yarn = yarn;
        vuecli = nodePackages."@vue/cli";
      };
      extraPath = lib.makeBinPath (builtins.attrValues devSDKs);
      intellij = pkgs.runCommand "intellij"
        { nativeBuildInputs = [ pkgs.makeWrapper ]; }
        ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.jetbrains.idea-ultimate}/bin/idea-ultimate \
            $out/bin/intellij \
            --prefix PATH : ${extraPath}
        '';
      clion = pkgs.runCommand "clion"
        { nativeBuildInputs = [ pkgs.makeWrapper ]; }
        ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.jetbrains.clion}/bin/clion \
            $out/bin/clion \
            --prefix PATH : ${extraPath}
        '';
    in { ... }: {
      home.packages = [ intellij clion ];
      home.file.".local/dev".source = let
          mkEntry = name: value: { inherit name; path = value; };
          entries = lib.mapAttrsToList mkEntry devSDKs;
        in pkgs.linkFarm "local-dev" entries;
    };
  };
}
