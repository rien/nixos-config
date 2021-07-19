{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.accentor;
  web = pkgs.mkYarnPackage rec {
    pname = "accentor-web";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "accentor";
      repo = "web";
      rev = "main";
      sha256 = "sha256-L0ifKjdsVZxB8a/BOZqyCOqSRzxE9wgPufHBNbopYX4=";
    };
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnNix = ./yarn.nix;
    buildPhase = ''
      cp deps/accentor/postcss.config.js .
      yarn run build
    '';
    installPhase = ''
      cp -r deps/accentor/dist $out
      rm $out/**/*.map
    '';
    distPhase = "true";
  };
  api = pkgs.fetchFromGitHub {
    owner = "accentor";
    repo = "api";
    rev = "main";
    sha256 = "sha256-uOVgwbs0DeHr+D/ihwjL4zMUDUrHlEV1HxCy/5jlJj0=";
  };
  gems = pkgs.bundlerEnv {
    name = "accentor-api-env";
    ruby = pkgs.ruby_3_0;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
    groups = [ "default" "development" "test" "production" ];
  };
  env = {
    BOOTSNAP_CACHE_DIR = "/var/tmp/accentor/bootsnap";
    DATABASE_URL = "postgresql://%2Frun%2Fpostgresql/accentor";
    FFMPEG_LOG_LOCATION = "/var/log/accentor/ffmpeg.log";
    FFMPEG_VERSION_LOCATION = "${cfg.home}/ffmpeg.version";
    PIDFILE = "/run/accentor/server.pid";
    RACK_ENV = "production";
    RAILS_ENV = "production";
    RAILS_LOG_TO_STDOUT = "yes";
    RAILS_STORAGE_PATH = "${cfg.home}/storage";
    RAILS_TRANSCODE_CACHE = "/var/tmp/accentor/transcode_cache";
  };
  exports = concatStringsSep
    "\n"
    (mapAttrsToList (name: value: "export ${name}=\"${value}\"") env);
  console = pkgs.writeShellScriptBin "accentor-console" ''
    set -ex
    ${exports}
    export $(cat ${cfg.environmentFile} | xargs)
    cd ${api}
    ${gems}/bin/bundle exec rails c
  '';
in
{
  options.services.accentor = {
    enable = mkEnableOption ''Accentor music server.

      Accentor provides an API through a Ruby on Rails application which can be
      accessed using the Web UI.
    '';

    home = mkOption {
      description = "The directory where Accentor will run.";
      default = "/var/lib/accentor";
      type = types.path;
    };

    hostname = mkOption {
      description = ''
        The virtual hostname on which nginx will host the API and Web UI.
      '';
      example = "accentor.example.com";
      type = types.str;
    };

    workers = mkOption {
      description = "Amount of background workers that should be spawned.";
      default = 4;
      example = 8;
      type = types.int;
    };

    environmentFile = mkOption {
      description = ''
        Path to a file containing secret environment variables that should be
        passed to Accentor. Currently this has to contain the SECRET_KEY_BASE
        environment variable which can be generated using rails secret.
      '';
      example = "/run/secrets/accentor";
      type = types.str;
    };

    nginx = mkOption {
      default = {
        forceSSL = true;
        enableACME = true;
      };
      example = {
        serverAliases = [
          "music.\${config.networking.domain}"
        ];
      };
      description = ''
        With this option, you can customize an nginx virtualHost which already
        has sensible defaults for Accentor. Set this to {} to just enable the
        virtualHost if you don't need any customization. If this is set to
        null (the default), no nginx virtualHost will be configured.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ console ];

    services.postgresql = {
      ensureUsers = [{
        name = "accentor";
        ensurePermissions = { "DATABASE accentor" = "ALL PRIVILEGES"; };
      }];
      ensureDatabases = [ "accentor" ];
    };

    systemd.tmpfiles.rules = [
      "d /run/accentor 0755 accentor accentor -"
      "d /var/log/accentor 0755 accentor accentor -"
      "d /var/tmp/accentor/transcode_cache 0755 accentor accentor -"
      "d /var/tmp/accentor/bootsnap 0755 accentor accentor -"
      "d ${cfg.home}/storage 0755 accentor accentor -"
    ];

    systemd.services = {
      accentor-api = {
        after = [ "network.target" "postgresql.service" ];
        requires = [ "postgresql.service" ];
        wantedBy = [ "multi-user.target" ];
        environment = env;
        path = [ pkgs.ffmpeg gems gems.wrappedRuby ];
        serviceConfig = {
          EnvironmentFile = cfg.environmentFile;
          Type = "simple";
          User = "accentor";
          Group = "accentor";
          Restart = "on-failure";
          WorkingDirectory = api;
          ExecStartPre = [
            "${gems}/bin/bundle exec rails db:migrate"
            "${gems}/bin/bundle exec rails ffmpeg:check_version"
          ];
          ExecStart = "${gems}/bin/bundle exec puma -C ${api}/config/puma.rb";
        };
      };
    } // (builtins.foldl' (x: y: x // y) { } (builtins.genList
      (n: {
        "accentor-worker${toString n}" = {
          after = [ "network.target" "accentor-api.service" "postgresql.service" ];
          requires = [ "accentor-api.service" "postgresql.service" ];
          wantedBy = [ "multi-user.target" ];
          environment = env;
          path = [ pkgs.ffmpeg gems gems.wrappedRuby ];
          serviceConfig = {
            EnvironmentFile = cfg.environmentFile;
            Type = "simple";
            User = "accentor";
            Group = "accentor";
            Restart = "on-failure";
            WorkingDirectory = api;
            ExecStart = "${gems}/bin/bundle exec rails jobs:work";
          };
        };

      }) cfg.workers));

    users.users.accentor = {
      group = "accentor";
      home = cfg.home;
      createHome = true;
      uid = 314;
    };
    users.groups.accentor.gid = 314;

    services.nginx.virtualHosts = mkIf (cfg.nginx != null) {
      "${cfg.hostname}" = mkMerge [ cfg.nginx {
        root = web;
        locations = {
          "/api" = {
            proxyPass = "http://localhost:3000";
            extraConfig = ''
              proxy_set_header X-Forwarded-Ssl on;
              client_max_body_size 40M;
            '';
          };
          "/rails" = {
            proxyPass = "http://localhost:3000";
            extraConfig = ''
              proxy_set_header X-Forwarded-Ssl on;
            '';
          };
          "/".extraConfig = ''
            autoindex on;
            try_files $uri $uri/ /index.html =404;
          '';
        };
      }];
    };
  };
}
