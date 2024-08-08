function journal {
  today=`date "+%Y-%m-%d"`
  if [ ! -d "${HOME}/workspace/journal" ]; then
    mkdir -p "${HOME}/workspace/journal"
  fi
  $EDITOR $HOME/workspace/journal/$today.md
}