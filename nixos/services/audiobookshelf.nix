{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.unstable.audiobookshelf ];

  services.audiobookshelf = {
    enable = true;
    port = 8234;
    package = pkgs.unstable.audiobookshelf;
    user = "nextcloud";
    group = "nextcloud";
    openFirewall = true;
    host = "0.0.0.0";
    dataDir = "nextcloud/data/jack/files/Media/Audiobooks";
  };
}
