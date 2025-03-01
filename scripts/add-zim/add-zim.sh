#!/usr/bin/env bash

folder=$(xh --follow "https://download.kiwix.org/zim" | htmlq --attribute href a | tail -n +7 | gum choose)
zim_file=$(xh --follow "https://download.kiwix.org/zim/${folder}" | htmlq --attribute href a | tail -n +6 | fzf)

if [[ $zim_file == '' ]]; then exit 1; fi
gum confirm "Do you want to download - $folder$zim_file ?" || exit 1

sudo true
if [ ! -d "/var/lib/kiwix/${folder}" ]; then
  sudo runuser -u kiwix -- mkdir -p "/var/lib/kiwix/${folder}"
fi
sudo runuser -u kiwix -- xh --follow --download "https://download.kiwix.org/zim/${folder}${zim_file}" --output "/var/lib/kiwix/${folder}${zim_file}"

sudo runuser -u kiwix -- kiwix-manage "/var/lib/kiwix/library.xml" add "/var/lib/kiwix/${folder}${zim_file}"
# sudo systemctl restart kiwix
