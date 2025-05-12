{ stdenv, config, lib, pkgs, ... }:
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
        inherit pkg-config ruby_3_1 ruby_3_2 yarn valgrind vale mono;
        dotnet = dotnet-sdk;
        openssl = symlinkJoin { name = openssl.pname; paths = [ openssl.dev openssl.debug ]; };
        rustc = symlinkJoin { name = rustc.pname; paths = [ rustc cargo gcc ]; };
        rust-src = rust.packages.stable.rustPlatform.rustLibSrc;
        java11 = jdk11;
        java17 = jdk17;
        java21 = jdk21;
        python = python3;
        node = nodejs;
        c = clang_14;
        make = gnumake;
        perf = linuxPackages.perf;
        dutch = hunspellDicts.nl_nl;
      };
      extraPath = lib.makeBinPath (builtins.attrValues devSDKs);
      idea-with-copilot = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea-ultimate [ "github-copilot" ];
      clion-with-copilot = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.clion [ "github-copilot" ];
      rust-rover-with-copilot = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.rust-rover [ "github-copilot" ];
      nix-ld-path = lib.makeLibraryPath [
        pkgs.stdenv.cc.cc pkgs.pkg-config pkgs.openssl.dev pkgs.dotnet-sdk pkgs.mono
      ];
      nix-ld = "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')";
      mkEditor = (editor: let
          name = editor.pname;
          withCopilot = pkgs.jetbrains.plugins.addPlugins editor [ "github-copilot" ];
        in pkgs.runCommand name
          { nativeBuildInputs = [ pkgs.makeWrapper ]; }
          ''
          mkdir -p $out/bin
          ln -s ${withCopilot}/share $out/share
          makeWrapper ${withCopilot}/bin/${name} \
            $out/bin/${name} \
            --prefix PATH : ${extraPath} \
            --set NIX_LD_LIBRARY_PATH "${nix-ld-path}" \
            --set NIX_LD "${nix-ld}"
          ''
      );
    in { ... }: {
      home.packages = with pkgs.jetbrains; map mkEditor [ idea-ultimate pycharm-professional rust-rover rider ];
      home.file.".local/dev".source = let
          mkEntry = name: value: { inherit name; path = value; };
          entries = lib.mapAttrsToList mkEntry devSDKs;
        in pkgs.linkFarm "local-dev" entries;
    };
  };
}
