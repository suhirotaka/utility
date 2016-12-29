# utility
Collects my utility scripts for daily use

## shell/ecs_login_by_service_name.sh
ecs_login_by_service_name.sh logins you to ECS instance or container by ECS service name.

### Usage
```
Usage:
  ecslogin [-f PRIVATE_KEY_FILE_NAME] [-c ECS_CLUSTER_NAME] [-d] ECS_SERVICE_NAME

Options:
  -f private key file name
  -c ECS cluster name
  -d directly login to ECS container
  -h print this
```

### System dependencies
- [jq](https://stedolan.github.io/jq/ "jq")
- [AWS CLI](https://aws.amazon.com/cli/ "AWS CLI")

### Installation
```
brew tap suhirotaka/shell-scripts
brew install ecslogin
```

### Motivation
It is not an easy thing to login to ECS container of a desired ECS service name, because we need complicated steps to look up which EC2 instance is running specific ECS container. I was so frustrated that I wrote this script.

<br />
***
<br />

## shell/command_bookmarks.sh
command_bookmarks.sh adds command bookmark functionality to your console.

Bookmarks are saved at ~/.commandBookmarks.

### Usage
```
Usage: cmdb [<action>] [<options>]

Actions:
   add       Add a bookmark
   ls        List bookmarks
   edit      Edit bookmarks
   rm        Delete a bookmark
   run       Run a bookmarked command

Options:
  --help     Print this
  --version  Show version
```

<br />
***
<br />

## aws_lambda/stopEc2Instance.js
stopEc2Instance.js is node script which stops EC2 instance of a desired tag name.

### Usage
You can refresh EC2 instances by following steps.

1. Set to run stopEc2Instance.js on AWS Lambda
2. Set instance's auto scaling more than 1

### Sytem dependencies
- node
- [AWS SDK for JavaScript](https://www.npmjs.com/package/aws-sdk "AWS SDK for JavaScript")

### Motivation
I found it may cause problems to keep EC2 instance running for a long time because of disk space shortage. It is good manner to refresh EC2 instance periodically for stable server operation.

<br />
***
<br />

## cloudfront_signed_cookie
cloudfront_signed_cookie contains scripts to use CloudFront's signed cookie.

### Usage
1. Edit signature/policy.json to set domain name, expiration time, etc.
2. Get base64 encoded policy and signature by running signature/get_policy.sh and signature/get_signature.sh
3. Set generated policy and signature to viewer's web browsers. The html in web_example demonstorates how you can do that.

[I wrote an article for detail.](http://qiita.com/suhirotaka/items/514a9e246779dc1b9489 "AWS CloudFront 署名付きcookieの作り方")

<br />
***
<br />

## ruby/mdfile_link_elasticsearch
mdfile_link_elasticsearch.rb runs Elasticsearch on linked URLs in a markdown format file.

### Usage
1. Run `bunlde install`
2. Create markdown format file on which Elasticsearch is run
3. Set created file name to MD_FILENAME in mdfile_link_elasticsearch.rb 
4. Run `ruby mdfile_link_elasticsearch.rb query`

### System dependencies
- ruby
- [elasticsearch gem](https://github.com/elastic/elasticsearch-ruby "elasticsearch gem")
