{ config, pkgs, ... }: {
  sops.secrets."matrix/private_key" = { };
  environment.systemPackages = [ pkgs.dendrite ];
  services.dendrite = {
    enable = true;
    httpPort = 8008;
    # httpsPort = 8438;
    settings = {
      global = {
        server_name = "meep.sh";
        private_key = config.sops.secrets."matrix/private_key".path;
      };
    };
  };
}
