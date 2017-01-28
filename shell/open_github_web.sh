#!/bin/bash

VERSION_CODE=1.0.0

# show usage
usage() {
  cat <<__EOS__
$(basename $0) opens github web page from local repository.

Usage: $(basename $0) [<REMOTE_NAME>]

If no REMOTE_NAME is given, "origin" will be used.

Options:
  --help     Print this
  --version  Show version
__EOS__
}

if [ -n "$2" ]; then
  echo 'Error: invalid options'
  exit 1
fi

case "$1" in
  -h | --help )
    usage
    exit 0
    ;;

  -v | --version )
    echo "$(basename $0) version $VERSION_CODE"
    exit 0
    ;;

  -* )
    echo 'Error: invalid options'
    exit 1
    ;;
esac

remote_name=$1
if [ -z "$remote_name" ]; then
  remote_name=origin
fi

cd .
git_remote="$(git remote -v show $remote_name)"
github_url=$(echo "$git_remote" | grep -E "Fetch[ ]+URL:" | grep -o -E "http[s]*:\/\/.+$")
if [ -z "$github_url" ]; then
  github_url=$(echo "$git_remote" | grep -E "Push[ ]+URL:" | grep -o -E "http[s]*:\/\/.+$")
fi

if [ -z "$github_url" ]; then
  echo 'Error: invalid url'
else
  echo "opening $github_url ..."
  open $github_url
fi
