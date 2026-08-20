{
  config,
  inputs,
  ...
}:
let
  secretsPath = builtins.toString inputs.secrets;
  homeDir = config.home.homeDirectory;
in
{
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
      # Shared remotebuild key for darwin hosts to SSH into NixOS builders
      # (NixOS hosts get this via sops-nix in distributed-builds.nix instead).
      "private_keys/remotebuild" = {
        path = "${homeDir}/.ssh/id_remotebuild";
      };
      "public_keys/remotebuild" = {
        path = "${homeDir}/.ssh/id_remotebuild.pub";
      };
    };
  };
}
