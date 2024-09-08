{ pkgs, ... }: {
  services.hydra = {
    enable = true;
    package = pkgs.hydra_unstable;
    hydraURL = "https://hydra.meep.sh";
    notificationSender = "ratatoskr@meep.sh";
    buildMachinesFiles = [];
    extraConfig = ''
      store_uri = s3://nix-cache?profile=nixbuilder&endpoint=s3.meep.sh&region=us-az-ph&compression=zstd&parallel-compression=true&write-nar-listing=1&ls-compression=br&log-compression=br&secret-key=/home/ratatoskr/.config/nix/secret.key
    '';
    useSubstitutes = true;
  };
}
