{ stdenv, config, lib, pkgs, custompkgs, ... }:
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
        rust-src = rust.packages.stable.rustPlatform.rustLibSrc;
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
        c = clang_14;
        make = gnumake;
        valgrind = valgrind;
      };
      extraPath = lib.makeBinPath (builtins.attrValues devSDKs);
      # Copilot
      addCopilot = (editor:
        with pkgs.jetbrains.plugins;
        let
          libPath = lib.makeLibraryPath [pkgs.glibc pkgs.gcc-unwrapped];
          copilot-plugin = (urlToDrv {
            name = "GitHub Copilot";
            url = "https://plugins.jetbrains.com/files/17718/331908/github-copilot-intellij-1.2.6.2594.zip";
            hash = "sha256-4wEfT+IA1XOD1VZ2qQ9eoP9W2b6W9AcWWd8ioqClFlI=";
            extra = {
              inputs = [ pkgs.patchelf pkgs.glibc pkgs.gcc-unwrapped ];
              commands = ''
                agent="copilot-agent/bin/copilot-agent-linux"
                orig_size=$(stat --printf=%s $agent)
                patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $agent
                patchelf --set-rpath ${libPath} $agent
                chmod +x $agent
                new_size=$(stat --printf=%s $agent)

                # https://github.com/NixOS/nixpkgs/pull/48193/files#diff-329ce6280c48eac47275b02077a2fc62R25
                ###### zeit-pkg fixing starts here.
                # we're replacing plaintext js code that looks like
                # PAYLOAD_POSITION = '1234                  ' | 0
                # [...]
                # PRELUDE_POSITION = '1234                  ' | 0
                # ^-----20-chars-----^^------22-chars------^
                # ^-- grep points here
                #
                # var_* are as described above
                # shift_by seems to be safe so long as all patchelf adjustments occur 
                # before any locations pointed to by hardcoded offsets

                var_skip=20
                var_select=22
                shift_by=$(expr $new_size - $orig_size)
                function fix_offset {
                  # $1 = name of variable to adjust
                  location=$(grep -obUam1 "$1" $agent | cut -d: -f1)
                  location=$(expr $location + $var_skip)

                  value=$(dd if=$agent iflag=count_bytes,skip_bytes skip=$location \
                   bs=1 count=$var_select status=none)
                  value=$(expr $shift_by + $value)

                  echo -n $value | dd of=$agent bs=1 seek=$location conv=notrunc
                }
                fix_offset PAYLOAD_POSITION
                fix_offset PRELUDE_POSITION
              '';
            };
          });
        in addPlugins editor [ copilot-plugin ]);
      idea-with-copilot = addCopilot pkgs.jetbrains.idea-ultimate;
      clion-with-copilot = addCopilot pkgs.jetbrains.clion;
      intellij = pkgs.runCommand "intellij"
        { nativeBuildInputs = [ pkgs.makeWrapper ]; }
        ''
          mkdir -p $out/bin
          makeWrapper ${idea-with-copilot}/bin/idea-ultimate \
            $out/bin/intellij \
            --prefix PATH : ${extraPath}
        '';
      clion = pkgs.runCommand "clion"
        { nativeBuildInputs = [ pkgs.makeWrapper ]; }
        ''
          mkdir -p $out/bin
          makeWrapper ${clion-with-copilot}/bin/clion \
            $out/bin/clion \
            --set NIX_CC ${devSDKs.c}/bin/cc \
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
