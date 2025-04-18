{ config, pkgs, ... }: {
  users.users.dendrite = {
    isSystemUser = true;
    group = config.users.groups.dendrite.name;
    home = "/var/lib/private/dendrite";
  };
  users.groups.dendrite = { };
  sops.secrets."matrix/private_key" = {
    mode = "0440";
    group = config.users.groups.dendrite.name;
  };
  sops.secrets."matrix/env_file" = {
    mode = "0440";
    group = config.users.groups.dendrite.name;
  };
  environment.systemPackages = [ pkgs.dendrite ];
  services.dendrite = {
    enable = true;
    httpPort = 8008;
    environmentFile = config.sops.secrets."matrix/env_file".path;
    settings = {
      global = {
        server_name = "meep.sh";
        private_key = config.sops.secrets."matrix/private_key".path;
      };
      client_api.registration_disabled = true;
      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
    };
  };
  # systemd.services.dendrite = {
  #   serviceConfig.SupplementaryGroups = [ config.users.groups.dendrite.name ];
  # };
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/private/dendrite 0755 ${config.users.users.dendrite.name} ${config.users.groups.dendrite.name}"
  # ];
}
