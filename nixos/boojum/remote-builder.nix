{
  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";

    openssh.authorizedKeys.keyFiles = [ ./remotebuild.pub ];
  };

  users.groups.remotebuild = {};

  nix = {
    nrBuildUsers = 32;
    settings = {
      trusted-users = [ "remotebuild" ];
      min-free = "10G";
      max-free = "20G";
      max-jobs = "auto";
      cores = 0;
    };
  };
}
