#!/usr/bin/env zsh

gitclean() {
  git remote prune origin
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
  git branch --merged "$DEFAULT_BRANCH" | \grep -v "$DEFAULT_BRANCH" | xargs -n 1 git branch -d
}

gitclean
