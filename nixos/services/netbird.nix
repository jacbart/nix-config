{ config
, lib
, pkgs
, ...
}:
let
  user = "root";
  group = "root";
  domain = "meep.sh";
  netbird_subdomain = "nb";
  zitadel_subdomain = "auth";

  zitadel_client_id = "";

  zitadel_netbird_client_id = "netbird";
  zitadel_netbird_client_secret = "";
in
{
  sops.secrets = {
    coturn-password = {
      owner = user;
      inherit group;
    };
    turn-secret = {
      owner = "turnserver";
      group = "turnserver";
    };
    netbird-data-encryption-key = {
      owner = user;
      inherit group;
    };
    # zitadel-client-id = {
    #   owner = user;
    #   inherit group;
    # };
    # zitadel-netbird-client-id = {
    #   owner = user;
    #   inherit group;
    # };
    # zitadel-netbird-client-secret = {
    #   owner = user;
    #   inherit group;
    # };
  };

  services.coturn = {
    enable = true;
    listening-ips = [ "0.0.0.0" ];
    listening-port = 3478;
    tls-listening-port = 5349;
    realm = "turn.${domain}";
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets.turn-secret.path;
    lt-cred-mech = true;
    min-port = 49152;
    max-port = 65535;
  };

  # wait for zitadel to start
  systemd.services.netbird-management.after = [ "zitadel.service" ];
  systemd.services.netbird-management.requires = [ "zitadel.service" ];
  systemd.services.netbird-signal.after = [ "zitadel.service" ];
  systemd.services.netbird-signal.requires = [ "zitadel.service" ];
  systemd.services.coturn.after = [ "zitadel.service" ];
  systemd.services.coturn.requires = [ "zitadel.service" ];

  services.netbird.server = {
    enable = true;
    enableNginx = lib.mkDefault true;
    domain = "${netbird_subdomain}.${domain}";

    dashboard = {
      enable = true;
      package = pkgs.netbird-dashboard;
      settings = {
        AUTH_AUTHORITY = "https://${zitadel_subdomain}.${domain}";
        AUTH_AUDIENCE = zitadel_client_id;
        AUTH_CLIENT_ID = zitadel_client_id;
        AUTH_CLIENT_SECRET = "";
        AUTH_REDIRECT_URI = "/auth";
        AUTH_SILENT_REDIRECT_URI = "/silent-auth";
        AUTH_SUPPORTED_SCOPES = "openid profile email offline_access api";
        NETBIRD_TOKEN_SOURCE = "accessToken";
        NGINX_SSL_PORT = "443";
        LETSENCRYPT_DOMAIN = "";
        LETSENCRYPT_EMAIL = "";
        USE_AUTH0 = "false";
      };
    };

    coturn = {
      passwordFile = config.sops.secrets.coturn-password.path;
      useAcmeCertificates = false;
      domain = lib.mkForce "turn.${domain}";
    };

    signal = {
      package = pkgs.netbird;
    };

    management = {
      oidcConfigEndpoint = "https://${zitadel_subdomain}.${domain}/.well-known/openid-configuration";
      package = pkgs.netbird;
      turnDomain = "turn.${domain}";
      turnPort = 3478;
      logLevel = "DEBUG";

      # dnsDomain = "${netbird_subdomain}.${domain}";
      # singleAccountModeDomain = "${netbird_subdomain}.${domain}";
      disableSingleAccountMode = true;
      disableAnonymousMetrics = true;
      extraOptions = [ "--metrics-port" "9094" ];

      settings = {
        Stuns = [
          {
            "Proto" = "udp";
            "URI" = "stun:turn.${domain}:3478";
            "Username" = "netbird";
            Password._secret = config.sops.secrets.coturn-password.path;
          }
        ];
        TURNConfig = {
          Turns = [
            {
              "Proto" = "udp";
              "URI" = "turn:turn.${domain}:3478";
              "Username" = "netbird";
              Password._secret = config.sops.secrets.coturn-password.path;
            }
          ];
          "CredentialsTTL" = "12h";
          Secret._secret = config.sops.secrets.turn-secret.path;
          "TimeBasedCredentials" = false;
        };
        "Signal" = {
          "Proto" = "https";
          "URI" = "${netbird_subdomain}.${domain}:443";
          "Username" = "";
          "Password" = null;
        };
        "ReverseProxy" = {
          "TrustedHTTPProxies" = [ ];
          "TrustedHTTPProxiesCount" = 0;
          "TrustedPeers" = [
            "0.0.0.0/0"
          ];
        };
        "Datadir" = "/var/lib/netbird-mgmt/data";
        DataStoreEncryptionKey._secret = config.sops.secrets.netbird-data-encryption-key.path;
        "StoreConfig" = {
          "Engine" = "sqlite";
        };
        "HttpConfig" = {
          "AuthIssuer" = "https://${zitadel_subdomain}.${domain}";
          "AuthAudience" = zitadel_client_id;
          "AuthKeysLocation" = "https://${zitadel_subdomain}.${domain}/oauth/v2/keys";
          "OIDCConfigEndpoint" = "https://${zitadel_subdomain}.${domain}/.well-known/openid-configuration";
          "IdpSignKeyRefreshEnabled" = false;
        };
        "IdpManagerConfig" = {
          "ManagerType" = "zitadel";
          "ClientConfig" = {
            "Issuer" = "https://${zitadel_subdomain}.${domain}";
            "TokenEndpoint" = "https://${zitadel_subdomain}.${domain}/oauth/v2/token";
            "ClientID" = zitadel_netbird_client_id;
            "ClientSecret" = zitadel_netbird_client_secret;
            "GrantType" = "client_credentials";
          };
          "ExtraConfig" = {
            "ManagementEndpoint" = "https://${zitadel_subdomain}.${domain}/management/v1";
          };
          "Auth0ClientCredentials" = null;
          "AzureClientCredentials" = null;
          "KeycloakClientCredentials" = null;
          "ZitadelClientCredentials" = null;
        };
        "DeviceAuthorizationFlow" = {
          "Provider" = "hosted";
          "ProviderConfig" = {
            "Audience" = zitadel_client_id;
            "Domain" = "https://${zitadel_subdomain}.${domain}";
            "ClientID" = zitadel_client_id;
            "ClientSecret" = "";
            "TokenEndpoint" = "https://${zitadel_subdomain}.${domain}/oauth/v2/token";
            "DeviceAuthEndpoint" = "https://${zitadel_subdomain}.${domain}/oauth/v2/device_authorization";
            "Scope" = "openid";
            "UseIDToken" = false;
            "RedirectURLs" = null;
          };
        };
        "PKCEAuthorizationFlow" = {
          "ProviderConfig" = {
            "Audience" = zitadel_client_id;
            "ClientID" = zitadel_client_id;
            "ClientSecret" = "";
            "Domain" = "";
            "AuthorizationEndpoint" = "https://${zitadel_subdomain}.${domain}/oauth/v2/authorize";
            "TokenEndpoint" = "https://${zitadel_subdomain}.${domain}/oauth/v2/token";
            "Scope" = "openid profile email offline_access api";
            "RedirectURLs" = [
              "https://${netbird_subdomain}.${domain}/auth"
              "https://${netbird_subdomain}.${domain}/silent-auth"
            ];
            "UseIDToken" = false;
          };
        };
      };
    };
  };

  # services.nginx = {
  #   enable = true;

  #   virtualHosts."${netbird_subdomain}.${domain}" = {
  #     locations = {
  #       "/" = {
  #         root = config.services.netbird.server.dashboard.finalDrv;
  #         tryFiles = "$uri $uri.html $uri/ =404";
  #       };
  #     };
  #   };
  # };
}
