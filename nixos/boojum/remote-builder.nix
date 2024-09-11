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
      min-free = 10 * 1024 * 1024;
      max-free = 50 * 1024 * 1024;
      max-jobs = "auto";
      cores = 8;
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
  };
}
