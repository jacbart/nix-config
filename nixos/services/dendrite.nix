{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.dendrite ];
  # services.dendrite = {
  #   enable = false;
  # };
}
