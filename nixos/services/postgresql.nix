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
      superuser_map_root  root        postgres
      superuser_map_01    postgres    postgres
      superuser_map_02    zitadel     postgres
      superuser_map_03    headscale   postgres
      superuser_map_04    nextcloud   postgres
      # Let other names login as themselves
      superuser_map    /^(.*)$     \1
    '';
  };
}
