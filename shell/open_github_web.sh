#!/bin/bash

VERSION_CODE=1.0.0

# show usage
usage() {
  cat <<__EOS__
$(basename $0) opens github web page from local repository

Usage: $(basename $0) <REMOTE_NAME>

Options:
  --help     Print this
  --version  Show version
__EOS__
}

case "$1" in
  "-h" | "--help" )
    usage
    exit 0
    ;;

  "--version" )
    echo "$(basename $0) version $VERSION_CODE"
    exit 0
    ;;
esac

remote_name=$1
if [ -z "$remote_name" ]; then
  usage
  exit 1
fi

cd .
github_url=$(git remote -v show $remote_name | grep "Fetch URL:" | grep -o -E "http[s]*:\/\/.+$")

if [ -z "$github_url" ]; then
  echo 'Invalid url'
else
  echo "opening $github_url ..."
  open $github_url
fi
