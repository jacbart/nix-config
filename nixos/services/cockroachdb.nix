{ pkgs, ... }: {
  services.cockroachdb = {
    enable = true;
    package = pkgs.cockroachdb-bin;
    insecure = true;
    listen.port = 26257;
    http.port = 8124;
  };
}
