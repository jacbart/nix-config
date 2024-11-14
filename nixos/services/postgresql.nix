{ ... }: {
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" "zitadel" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "zitadel";
        ensureDBOwnership = true;
      }
    ];
  };
}
