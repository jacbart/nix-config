{ config, inputs, ... }: let
  secretsPath = builtins.toString inputs.mySecrets;
  homeDir = config.home.homeDirectory;
in {
  sops = {
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "private_keys/ratatoskr" = {
        path = "${homeDir}/.ssh/id_ratatoskr";
      };
      "private_keys/ratatoskr-sk" = {
        path = "${homeDir}/.ssh/id_ratatoskr_sk";
      };
      "public_keys/ratatoskr" = {
        path = "${homeDir}/.ssh/id_ratatoskr.pub";
      };
      "public_keys/ratatoskr-sk" = {
        path = "${homeDir}/.ssh/id_ratatoskr_sk.pub";
      };
    };
  };
}
