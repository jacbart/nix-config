{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    departure-mono
  ];
}
