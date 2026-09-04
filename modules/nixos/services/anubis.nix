{ lib, ... }:
{
  # Enable the Anubis service
  # Anubis sits in front of nginx to provide bot protection and filtering
  services.anubis = {
    # Define one or more Anubis instances
    instances = {
      public-proxy = {
        # Enable the instance
        enable = true;

        # Settings passed to Anubis as environment variables
        # See: https://anubis.techaro.lol/docs/admin/installation/#environment-variables
        settings = {
          # Address to bind the public-facing proxy
          # Anubis listens on HTTP port 80 and forwards to nginx on 8080
          BIND = "0.0.0.0:80";
          BIND_NETWORK = "tcp";

          # Address for metrics endpoint (optional, for Prometheus)
          METRICS_BIND = "127.0.0.1:8081";
          METRICS_BIND_NETWORK = "tcp";

          # Target service that Anubis protects (nginx reverse proxy)
          # nginx listens on localhost:8080 for HTTP traffic from Anubis
          # nginx also handles HTTPS (port 443) directly for TLS termination
          TARGET = "http://127.0.0.1:8080";
        };
      };
    };

    # Optional: set default options for all instances
    defaultOptions = {
      # You can set global defaults here if needed
    };
  };

  # Anubis runs as a hardened DynamicUser with an empty capability set, so it
  # cannot bind the privileged port 80. Grant only CAP_NET_BIND_SERVICE.
  # PrivateUsers must stay off: a private user namespace has no capabilities in
  # the host namespace, so CAP_NET_BIND_SERVICE could not bind port 80.
  systemd.services."anubis-public-proxy".serviceConfig = {
    CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    AmbientCapabilities = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    PrivateUsers = lib.mkForce false;
  };

  # Ensure the service listens on the desired ports
  # Anubis handles HTTP (port 80) and forwards to nginx on 8080
  # nginx handles HTTPS (port 443) directly for TLS termination
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
