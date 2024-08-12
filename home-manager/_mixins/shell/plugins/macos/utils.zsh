## JAVA
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

## Alias
alias copy="pbcopy"
alias grep="grep -RIns --color=auto --exclude=\"tags\""
alias lsusb="system_profiler SPUSBDataType"
alias newmacaddr="openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//' | xargs sudo ifconfig en0 ether"
alias showhidden="defaults write com.apple.finder AppleShowAllFiles"

# colored echo func
function cecho() {
  local code="\033["
  case "$1" in
    black  | bk) color="${code}0;30m";;
    red    |  r) color="${code}1;31m";;
    green  |  g) color="${code}1;32m";;
    yellow |  y) color="${code}1;33m";;
    blue   |  b) color="${code}1;34m";;
    purple |  p) color="${code}1;35m";;
    cyan   |  c) color="${code}1;36m";;
    gray   | gr) color="${code}0;37m";;
    *) local text="$1"
  esac
  [ -z "$text" ] && local text="$color$2${code}0m"
  echo "$text"
}

# get the last date timemachine was run
function lastm() {
  local last=`defaults read /Library/Preferences/com.apple.TimeMachine | rg ReferenceLocalSnapshotDate | awk '{print $3}' | cut -d '"' -f 2`
  local last_days=`date -j -f '%Y-%m-%d' "$last" '+%s' | awk '{print int($1/86400)}'`
  local today=`date "+%Y-%m-%d"`
  local today_days=`date -j -f '%Y-%m-%d' "$today" '+%s' | awk '{print int($1/86400)}'`
  local diff=`expr $today_days - $last_days`
  if [[ "$diff" -eq 0 ]]; then
    echo $last
  elif [[ "$diff" -le 7 ]]; then
    cecho y "$last [$diff day(s) ago]"
  else
    cecho r "$last [$diff day(s) ago]"
  fi
}
