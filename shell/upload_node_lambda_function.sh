#!/bin/bash

VERSION_CODE=1.0.0

# show usage
usage() {
  cat <<__EOS__
$(basename $0) builds and uploads AWS lambda function written by Node.js.

Usage: $(basename $0) <SOURCE_DIRECTORY> <FUNCTION_NAME>

Options:
  --help     Print this
  --version  Show version
__EOS__
}

if [ -n "$3" ]; then
  echo 'Error: invalid options'
  exit 1
fi

case "$1" in
  -h | --help | '')
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

source_dir=$1
if [ ! -d "$source_dir" ]; then
  echo 'Error: source directory not found'
  exit 1
fi
function_name=$2
if [ -z "$function_name" ]; then
  echo 'Error: no function name given'
  exit 1
fi
if ! type "aws" > /dev/null 2>&1; then
  echo "Error: aws command not found."
  exit 1
fi
zipped_file=".${function_name}_$(date '+%s').zip"

cd $source_dir
npm install
zip -r $zipped_file *.js node_modules
aws lambda update-function-code --function-name $function_name --zip-file fileb://$(pwd)/$zipped_file
echo "Lambda function upload successful"
