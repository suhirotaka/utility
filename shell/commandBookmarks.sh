#!/bin/bash

BM_FILENAME=~/.command_bookmarks
VERSION_CODE=1.0.0

# "Add" option
if [[ "$1" = "add" ]]; then
  if [ -n "$2" ]; then
    echo "${@:2}" >> $BM_FILENAME
    echo "Added a new command bookmark."
  else
    echo "Please specify a command to be added."
    exit 1
  fi

# "List" option
elif [[ "$1" = "ls" ]]; then
  line_num=1
  cat $BM_FILENAME | while read line
  do
    echo $line_num: $line
    line_num=$(($line_num + 1))
  done

# "Edit" option
elif [[ "$1" = "edit" ]]; then
  "${EDITOR:-vi}" $BM_FILENAME

# "Remove" option
elif [[ "$1" = "rm" ]]; then
  if [[ ! "$2" =~ ^[0-9]+$ ]]; then
    echo "Invalid command number specified."
    exit 1
  fi
  sed -i -e "${2},${2}d" $BM_FILENAME

# "Run" option
elif [[ "$1" = "run" ]]; then
  if [[ ! "$2" =~ ^[0-9]+$ ]]; then
    echo "Invalid command number specified."
    exit 1
  fi
  run_command=`sed -n ${2}p $BM_FILENAME`
  if [[ -z "$run_command" ]]; then
    echo "Command not found."
    exit 1
  fi
  echo "$(basename $0): Running \`$run_command\`"
  eval $run_command

# "--help" option
elif [[ "$1" = "--help" ]]; then
  cat <<__EOS__
$(basename $0) is a tool for command bookmarks

Usage: $(basename $0) <action> [<options>]

Actions:
   add       Add a bookmark
   ls        List bookmarks
   edit      Edit bookmarks
   rm        Delete a bookmark
   run       Run a bookmarked command

Options:
  --help     Print this
  --version  Show version
__EOS__

# "--version" option
elif [[ "$1" = "--version" ]]; then
  echo "$(basename $0) version $VERSION_CODE"

# other actions
else
  echo "Unknown action specified."
  exit 1
fi
