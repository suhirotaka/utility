#!/bin/bash

#hist_filename=~/.bash_history
bm_filename=~/.command_bookmarks
#HISTFILE=$hist_filename
#set -o history

if [[ "$1" = "add" ]]; then
  # "Add" option
  #last_command=`history | tail -n 2 | head -n 1 | sed -e 's/ \{1,\}[0-9]\{1,\} \{1,\}//'`
  if [ -n "$2" ]; then
    echo "${@:2}" >> $bm_filename
    echo "Added a new command bookmark."
  else
    echo "No bookmark command specified."
    exit 1
  fi
elif [[ "$1" = "ls" ]]; then
  # "List" option
  line_num=1
  cat $bm_filename | while read line
  do
    echo $line_num: $line
    line_num=$(($line_num + 1))
  done
elif [[ "$1" = "edit" ]]; then
  # "Modify" option
  vi $bm_filename
elif [[ "$1" = "rm" ]]; then
  # "Delete" option
  if [[ ! "$2" =~ ^[0-9]+$ ]]; then
    echo "Invalid command number specified."
    exit 1
  fi
  sed -i -e "${2},${2}d" ~/.command_bookmarks
elif [[ "$1" = "run" ]]; then
  if [[ ! "$2" =~ ^[0-9]+$ ]]; then
    echo "Invalid command number specified."
    exit 1
  fi
  # "Run specified command" option
  run_command=`sed -n ${2}p $bm_filename`
#echo $run_command
  eval $run_command
elif [[ "$1" = "--help" ]]; then
  cat << EOS
cmdb is a tool for command bookmarks

Usage: cmdb <command> [<args>]

Commands:
   add      Add a command
   ls       List commands
   edit     Edit commands
   rm       Delete a command
   run      Run a command

Options:
  --help    Print this
EOS
else
  echo "Invalid command specified."
  exit 1
fi
