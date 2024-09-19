{ config, ... }: {
  sops.secrets."wireguard/server/endpoint" = {};
  sops.secrets."wireguard/server/public" = {};
  sops.secrets."wireguard/ash/private" = {};

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "192.168.2.3/32" ];
      dns = [ "192.168.2.1" ];
      privateKeyFile = config.sops.secrets."wireguard/ash/private".path;
      
      peers = [
        {
          publicKey = config.sops.secrets."wireguard/server/public".path;
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = config.sops.secrets."wireguard/server/endpoint";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
