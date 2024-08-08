alias install="brew install"
alias update="brew update && brew upgrade"

function remove() {
  brew rm $1
  brew rm $(join <(brew leaves) <(brew deps $1))
}