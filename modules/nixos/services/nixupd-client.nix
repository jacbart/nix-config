{
  config,
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.nixupd.nixosModules.nixupd ];

  sops.secrets."nixupd-secret" = {
    group = "nixupd";
    mode = "0640";
  };

  services.nixupd = {
    enable = true;
    configurePostBuildHook = true;
    atticConfigPath = config.sops.secrets."nixupd-secret".path;
    caches = [
      {
        name = "nix-cache.${vars.domain}";
        cacheRef = "nix-cache.${vars.domain}:nix-cache.${vars.domain}";
      }
    ];
    socketPath = "/var/run/nixupd/nixupd.sock";
    logLevel = "info";
  };
}
