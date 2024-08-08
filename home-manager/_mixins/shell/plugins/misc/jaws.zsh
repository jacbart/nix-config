function jawson {
  export JAWS_CONFIG_KEY=$(op item get JAWS_CONFIG_KEY --fields label=password)
}

function jawsoff {
  unset JAWS_CONFIG_KEY
}

function jaws-op {
  JAWS_CONFIG_KEY=$(op item get JAWS_CONFIG_KEY --fields label=password) jaws "$@"
}
#alias jaws=jaws-op