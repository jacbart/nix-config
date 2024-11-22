_: {
  # https://nixos.wiki/wiki/Docker
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };
}
