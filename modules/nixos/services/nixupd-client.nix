{
  config,
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.nixupd.nixosModules.nixupd ];

  sops.secrets."harmonia/secret" = {
    group = "nixupd";
    mode = "0640";
  };

  services.nixupd = {
    enable = true;
    generateKey = false;
    configurePostBuildHook = true;
    cacheName = "nix-cache.${vars.domain}";
    caches = [
      {
        name = "nix-cache.${vars.domain}";
        endpoint = "https://nix-cache.${vars.domain}";
        secretKeyPath = config.sops.secrets."harmonia/secret".path;
      }
    ];
    socketPath = "/var/run/nixupd/nixupd.sock";
    compression = "zstd";
    logLevel = "info";
  };
}
