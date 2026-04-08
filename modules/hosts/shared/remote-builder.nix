{
  cores,
  keyFile,
}:
{
  services.openssh.settings.KbdInteractiveAuthentication = false;

  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";

    openssh.authorizedKeys.keyFiles = [ keyFile ];
  };

  users.groups.remotebuild = { };

  nix = {
    nrBuildUsers = 32;
    settings = {
      trusted-users = [
        "remotebuild"
        "@wheel"
      ];
      min-free = 10 * 1024 * 1024;
      max-free = 50 * 1024 * 1024;
      max-jobs = "auto";
      inherit cores;
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryAccounting = true;
    MemoryMax = "90%";
    OOMScoreAdjust = 500;
  };
}
