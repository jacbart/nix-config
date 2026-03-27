{ ... }:
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

          # Upstream proxy/backend server that Anubis will protect
          # This is an alias for TARGET in some Anubis versions
          UPSTREAM = "http://127.0.0.1:8080";

          # Bot detection policy to block AI scrapers and crawlers
          # Must be a JSON string for environment variable
          botPolicy = builtins.toJSON {
            rules = [
              {
                name = "block-ai-scrapers";
                condition = "userAgent matches '.*(GPTBot|ChatGPT|Google-Extended|anthropic-ai|Claude-Web|CCBot|PerplexityBot|YouBot|Bingbot|BingPreview).*'";
                action = "block";
              }
              {
                name = "block-common-bots";
                condition = "userAgent matches '.*(bot|crawler|spider|scraper|crawling).*'";
                action = "block";
              }
              {
                name = "block-empty-user-agents";
                condition = "userAgent == ''";
                action = "block";
              }
              {
                name = "allow-legitimate-bots";
                condition = "userAgent matches '.*(Googlebot|Bingbot|Slurp|DuckDuckBot|Baiduspider|YandexBot|facebookexternalhit|Twitterbot|LinkedInBot|WhatsApp|Applebot|ia_archiver).*'";
                action = "allow";
              }
              {
                name = "allow-healthy-traffic";
                condition = "true";
                action = "allow";
              }
            ];
          };
        };
      };
    };

    # Optional: set default options for all instances
    defaultOptions = {
      # You can set global defaults here if needed
    };
  };

  # Ensure the service listens on the desired ports
  # Anubis handles HTTP (port 80) and forwards to nginx on 8080
  # nginx handles HTTPS (port 443) directly for TLS termination
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
