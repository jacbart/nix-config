{ pkgs , ... }: {
  home.packages = with pkgs; [
    mprocs
  ];
}
