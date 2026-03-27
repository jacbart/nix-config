{
  config,
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.nixupd.nixosModules.nixupd ];

  sops.secrets."nixupd-cache-key" = {
    group = "nixupd";
  };

  services.nixupd = {
    enable = true;
    generateKey = false;
    cacheName = "nix-cache.${vars.domain}";
    caches = [
      {
        name = "nix-cache.${vars.domain}";
        endpoint = "https://nix-cache.${vars.domain}";
        secretKeyPath = config.sops.secrets."nixupd-cache-key".path;
      }
    ];
    socketPath = "/run/nixupd/nixupd.sock";
    compression = "zstd";
    logLevel = "info";
  };
}
