{ config, ... }:
{
  sops.secrets."wireguard/ash/psKey" = { };
  sops.secrets."wireguard/ash/private" = { };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "192.168.2.3/32" ];
      dns = [ "192.168.0.120" ];
      privateKeyFile = config.sops.secrets."wireguard/ash/private".path;

      peers = [
        {
          publicKey = "aGYKutq/jSiCOnjgJ0nZaM25qfMnEh3lHoyxwLGCVxo=";
          presharedKeyFile = config.sops.secrets."wireguard/ash/psKey".path;
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "192.168.0.120:51999";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
