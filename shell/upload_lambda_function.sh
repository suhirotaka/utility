#!/bin/bash

# Usage: `./upload_lambda_function.sh ~/src/scripts/task_scripts/lambda/importToMailchimp/importToMailchimp.js import_to_mailchimp`

source_file=$1
zipped_file=function_$(date '+%s').zip
cd $(dirname $source_file)
npm install
zip -r $zipped_file $source_file node_modules
aws lambda update-function-code --function-name $2 --zip-file fileb://$(pwd)/$zipped_file
