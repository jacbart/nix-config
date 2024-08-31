
{ inputs, pkgs, username, ... }: let
  inherit (pkgs.stdenv) isDarwin;
  secretsPath = builtins.toString inputs.mySecrets;
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in {
  systemd.tmpfiles.rules = [
    "f ${homeDir}/.ssh/id_ratatoskr.pub - ${username} users - -"
    "f ${homeDir}/.ssh/id_ratatoskr_sk.pub - ${username} users - -"
  ];
  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      "public_keys/ratatoskr" = {
        path = "${homeDir}/.ssh/id_ratatoskr.pub";
      };
      "public_keys/ratatoskr_sk" = {
        path = "${homeDir}/.ssh/id_ratatoskr_sk.pub";
      };
    };
  };

}
