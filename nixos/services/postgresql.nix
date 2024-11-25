_: {
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" "zitadel" "headscale" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "zitadel";
        ensureDBOwnership = true;
      }
      {
        name = "headscale";
        ensureDBOwnership = true;
      }
    ];
    identMap = ''
      # ArbitraryMapName systemuser DBUser
        superuser_map    root        postgres
        superuser_map    ratatoskr   postgres
        superuser_map    postgres    postgres
        superuser_map    zitadel     postgres
        superuser_map    headscale   postgres
        # Let other names login as themselves
        superuser_map    /^(.*)$     \1
    '';
  };
}
