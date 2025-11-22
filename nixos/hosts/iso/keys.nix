{ pkgs, ... }:
let
  service_user = "nixos";

  # meep's github ssh key
  sshkey = pkgs.writeText "meep-ssh-key" '''';
  # meep's age key for sops
  agekey = pkgs.writeText "meep-age-key" '''';
in
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install" ''
      #! ${pkgs.bash}/bin/bash
      set -e
      set -u
      set -o pipefail

      # check if ssh folder exists
      if [ ! -d ~/.ssh ]; then
        echo "Setting up user ssh"
        mkdir -p ~/.ssh
        chmod 0700 ~/.ssh
      fi

      # check if ssh key exists
      if [ ! -f ~/.ssh/id_github ]; then
        cat "${sshkey}" > ~/.ssh/id_github
        chown ${service_user}:users ~/.ssh/id_github
        chmod 0400 ~/.ssh/id_github
      fi

      # check if ssh config exists
      if [ ! -f ~/.ssh/config ]; then
        echo "Host github.com" > ~/.ssh/config
        echo "  IdentityFile ~/.ssh/id_github" >> ~/.ssh/config
        echo "  User git" >> ~/.ssh/config
        chmod 0600 ~/.ssh/config
      fi

      # check if age key exists
      if [ ! -f ~/.config/sops/age/keys.txt ]; then
        echo "Setting up user SOPS key"
        mkdir -p ~/.config/sops/age
        cat "${agekey}" > ~/.config/sops/age/keys.txt
        chown ${service_user}:users ~/.config/sops/age/keys.txt
        chmod 0600 ~/.config/sops/age/keys.txt
      fi

      # root ssh
      if [ ! -d /root/.ssh ]; then
        echo "Setting up root ssh"
        sudo true
        sudo mkdir -p /root/.ssh
        sudo chmod 0700 /root/.ssh
      fi

      # check if ssh key exists
      if [ ! -f /root/.ssh/id_github ]; then
        sudo true
        cat "${sshkey}" | sudo tee -a /root/.ssh/id_github
        sudo chown root:root /root/.ssh/id_github
        sudo chmod 0400 /root/.ssh/id_github
      fi

      # check if ssh config exists
      if [ ! -f /root/.ssh/config ]; then
        sudo true
        echo "Host github.com" | sudo tee -a /root/.ssh/config
        echo "  IdentityFile /root/.ssh/id_github" | sudo tee -a /root/.ssh/config
        echo "  User git" | sudo tee -a /root/.ssh/config
        sudo chown root:root /root/.ssh/config
        sudo chmod 0600 /root/.ssh/config
      fi

      # check if age key exists
      if [ ! -f /root/.config/sops/age/keys.txt ]; then
        echo "Setting up root SOPS key"
        sudo true
        sudo mkdir -p /root/.config/sops/age
        cat "${agekey}" | sudo tee -a /root/.config/sops/age/keys.txt
        sudo chown root:root /root/.config/sops/age/keys.txt
        sudo chmod 0600 /root/.config/sops/age/keys.txt
      fi

      ${pkgs.scripts.install-system}/bin/install-system $@
    '')
  ];
}
