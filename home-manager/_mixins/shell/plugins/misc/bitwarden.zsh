#eval "$(bw completion --shell zsh); compdef _bw bw;"

function bwon() {
  if ! $(bw login --check --quiet); then
    bw login --method 3 --quiet
  fi
  if [ -z ${BW_SESSION+x} ]; then
    echo "Unlock vault"
    export BW_SESSION=$(bw unlock --raw)
  fi
  bw sync --quiet
}

function bwoff() {
  bw lock --quiet
  unset BW_SESSION
}

function bp() {
  bwon; wait
  if [[ $[#] == 0 ]]; then
    bw list items | jq -r '.[].name' | fzf | xargs bw get password
  elif [[ $[#] == 1 ]]; then
    bw get password $1
  else
    echo "one or less args allowed"
  fi
}

function bn() {
  bwon; wait
  if [[ $[#] == 0 ]]; then
    bw list items | jq -r '.[].name' | fzf | xargs bw get notes
  elif [[ $[#] == 1 ]]; then
    bw get notes $1
  else
    echo "only one and less args allowed"
  fi
}

function bfields() {
  bwon; wait
  if [[ $[#] == 0 ]]; then
    bw list items | jq -r '.[].name' | fzf | xargs bw get item | jq -r '. | .fields[].name,.fields[].value'
  elif [[ $[#] == 1 ]]; then
    bw get item $1 | jq -r '. | .fields[].name,.fields[].value'
  else
    echo "only one and less args allowed"
  fi
}

function send() {
  bwon; wait
  if [[ $1 == "clean" ]]; then
    IFS=$'\n' ID_LIST=($(bw send list | jq -r '.[].id'))

    for i in $ID_LIST; do
      bw send delete $i
    done
  else
    bw send --deleteInDays 1 --maxAccessCount 1 --file "$1" | jq -r '.accessUrl'
  fi
}