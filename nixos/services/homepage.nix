{ pkgs
, ...
}:
let
  homepage-bookmarks = pkgs.writeTextFile {
    name = "bookmarks.yaml";
    executable = false;
    destination = "/var/lib/private/homepage-dashboard/bookmarks.yaml";
    text = ''
      ---
      # For configuration options and examples, please see:
      # https://gethomepage.dev

      - Social:
          - Mastodon:
              - abbr: MD
                href: https://infosec.exchange/home

      - Entertainment:
          - YouTube:
              - abbr: YT
                href: https://youtube.com/
          - Plex:
              - abbr: PL
                href: https://app.plex.tv/

      - Homelab:
        - Nextcloud:
          - addr: NC
            href: https://cloud.meep.sh/
        - AudiobookShelf:
          - addr: AS
            href: https://books.meep.sh/
        - Minio:
          - addr: MO
            href: https://minio.meep.sh/
        - Zitadel:
          - addr: ZD
            href: https://zitadel.meep.sh/
    '';
  };
in
{
  services.homepage-dashboard = {
    enable = true;
    package = pkgs.unstable.homepage-dashboard;
    openFirewall = true;
  };

  environment.systemPackages = [ homepage-bookmarks ];
}
