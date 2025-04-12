{ config, pkgs, ... }: {
  users.groups.matrix = { };
  sops.secrets."matrix/private_key" = {
    mode = "0440";
    group = config.users.groups.matrix.name;
  };
  environment.systemPackages = [ pkgs.dendrite ];
  services.dendrite = {
    enable = true;
    httpPort = 8008;
    settings = {
      global = {
        server_name = "meep.sh";
        private_key = config.sops.secrets."matrix/private_key".path;
      };
    };
  };
  systemd.services.dendrite = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.matrix.name ];
  };
}
