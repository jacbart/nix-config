{ config, inputs, ... }: let
  secretsPath = builtins.toString inputs.mySecrets;
  homeDir = config.home.homeDirectory;
  homeKeyPath = "${homeDir}/.config/sops/age/keys.txt";
in {
  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed22519_key" ];
      keyFile = if builtins.pathExists homeKeyPath then homeKeyPath else "/var/lib/sops-nix/key.txt";
    };

    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "private_keys/ratatoskr" = {
        path = "${homeDir}/.ssh/id_ratatoskr";
      };
      "private_keys/ratatoskr_sk" = {
        path = "${homeDir}/.ssh/id_ratatoskr_sk";
      };
    };
  };
}
