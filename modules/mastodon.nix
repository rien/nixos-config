{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.mastodon;
in {
  options.custom.mastodon = {
    enable = mkOption {
      example = true;
      default = false;
    };

    vapidPublicKeyFile = mkOption {
      example = "/run/agenix/mastodon-vapid-pubkey";
      type = lib.types.str;
    };

    vapidPrivateKeyFile = mkOption {
      example = "/run/agenix/mastodon-vapid-privkey";
      type = lib.types.str;
    };

    secretKeyBaseFile = mkOption {
      example = "/run/agenix/mastodon-secretkey";
      type = lib.types.str;
    };

    otpSecretFile = mkOption {
      example = "/run/agenix/mastodon-otpsecret";
      type = lib.types.str;
    };

    localDomain = mkOption {
      example = "mastodon.example.com";
      type = lib.types.str;
    };
  };

  config = mkIf cfg.enable{
    services.mastodon = {
      enable = true;
      configureNginx = true;

      # Postfix should already be enabled
      smtp = {
        createLocally = false;
        fromAddress = "mastodon@${ cfg. localDomain }";
      };
      extraConfig = {
        SMTP_OPENSSL_VERIFY_MODE = "none";
      };

      # Will set the DB user
      database.createLocally = true;

      # Will setup redis
      redis.createLocally = true;


      localDomain = cfg.localDomain;
      vapidPublicKeyFile = cfg.vapidPublicKeyFile;
      vapidPrivateKeyFile = cfg.vapidPrivateKeyFile;
      secretKeyBaseFile = cfg.secretKeyBaseFile;
      otpSecretFile = cfg.otpSecretFile;
    };
  };
}
