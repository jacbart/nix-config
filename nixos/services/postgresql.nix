{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "nextcloud"
      "zitadel"
      "headscale"
    ];
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
      superuser_map    zitadel     postgres
      superuser_map    root        postgres
      superuser_map    headscale   postgres
      superuser_map    nextcloud   postgres
      # Let other names login as themselves
      superuser_map    /^(.*)$     \1
    '';
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method optional_ident_map
      local sameuser  all     peer        map=superuser_map
    '';
  };
}
