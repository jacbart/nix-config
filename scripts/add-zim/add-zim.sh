#!/usr/bin/env zsh

KIWIX_USER="kiwix"
KIWIX_DIR="/var/lib/kiwix/"
PATH=$(xh --follow "https://download.kiwix.org/zim" | htmlq --attribute href a | tail -n +7 | gum choose)
ZIM_FILE=$(xh --follow "https://download.kiwix.org/zim/${PATH}" | htmlq --attribute href a | tail -n +6 | fzf)

if [[ $ZIM_FILE == '' ]]; then exit 1; fi
gum confirm "Download - $PATH$ZIM_FILE?" || exit 1

sudo true || exit 1
if [ ! -d "${KIWIX_DIR}${PATH}" ]; then
  sudo runuser -u "${KIWIX_USER}" -- mkdir -p "${KIWIX_DIR}${PATH}"
fi
sudo xh --follow --download "https://download.kiwix.org/zim/${DL_FOLDER}${ZIM_FILE}" --output "${KIWIX_DIR}${DL_FOLDER}${ZIM_FILE}" || exit 1
sudo chown -R "${KIWIX_USER}" "${KIWIX_DIR}${DL_FOLDER}${ZIM_FILE}" || exit 1

sudo runuser -u "${KIWIX_USER}" -- kiwix-manage "${KIWIX_DIR}library.xml" add "${KIWIX_DIR}${DL_FOLDER}${ZIM_FILE}" || exit 1
