{ pkgs, ... }: {
  # environment.etc = {
  #   "fail2ban/filter.d/caddy-status.conf".text = ''
  #     [Definition]
  #     failregex = ^.*"remote_ip":"<HOST>",.*?"status":(?:401|403|500),.*$
  #     ignoreregex =
  #     datepattern = LongEpoch
  #   '';
  # };

  services.fail2ban = {
    enable = true;
    extraPackages = [ pkgs.ipset ];
    # Ban IP after 3 failures
    maxretry = 3;
    ignoreIP = [
      # Whitelist some subnets
      "192.168.1.0/24"
      "192.168.4.0/24"
      "100.100.100.100/10"
      "nb.meep.sh"
    ];
    bantime = "24h"; # Ban IPs for one day on the first ban
    bantime-increment = {
      enable = true; # Enable increment of bantime after each violation
      formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      # multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h"; # Do not ban for more than 1 week
      overalljails = true; # Calculate the bantime based on all the violations
    };
    banaction = "iptables-ipset-proto6-allports";
    # jails = {
    #   caddy-status.settings = {
    #     enabled = true;
    #     port = "http,https";
    #     filter = "caddy-status";
    #     logpath = "/var/log/caddy/*.access.log";
    #     maxretry = 5;
    #   };
    # };
  };
}
