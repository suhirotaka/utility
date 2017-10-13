#!/bin/bash

in_dir=$1
out_dir=$2
in_file_name='*'

find "$in_dir" -type d -name "$in_file_name" -print0 | while IFS= read -r -d '' excel_dir; do
  echo $excel_dir
  find "$excel_dir" -type f -name '*xls*' -print0 | while IFS= read -r -d '' in_file; do
    out_file_name="$(echo $(basename "$in_file") | sed 's/\.[^\.]*$//').csv"
    xlsx2csv "$in_file" "$out_dir/$out_file_name"
    echo "Converted excel to csv ($in_file => $out_dir/$out_file_name)"
  done
done
