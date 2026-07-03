{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "sf";

  runtimeInputs = with pkgs; [
    nodejs_24
  ];

  text = ''
    exec npx -y @salesforce/cli@2.140.6 "$@"
  '';

  meta = with pkgs.lib; {
    description = "Salesforce CLI (sf) — wrapper around npx @salesforce/cli";
    homepage = "https://github.com/forcedotcom/cli";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
