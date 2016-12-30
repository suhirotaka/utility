# utility
my utility scripts collection for daily use

- [shell/ecs_login_by_service_name.sh](#item1)
- [shell/command_bookmarks.sh](#item2)
- [aws_lambda/stopEc2Instance.js](#item3)
- [cloudfront_signed_cookie](#item4)
- [ruby/mdfile_link_elasticsearch](#item5)

<br />
<br />

## <a name="item1"></a>shell/ecs_login_by_service_name.sh
ecs_login_by_service_name.sh logins you to ECS instance or container by ECS service name.

### Installation
```
brew tap suhirotaka/utility
brew install ecslogin
```

### Usage
```
Usage:
  ecslogin [-f PRIVATE_KEY_FILE_NAME] <-c ECS_CLUSTER_NAME> [-d] <ECS_SERVICE_NAME>

Options:
  -f private key file name
  -c ECS cluster name
  -d directly login to ECS container
  -h print this
```

### System dependencies
- [jq](https://stedolan.github.io/jq/ "jq")
- [AWS CLI](https://aws.amazon.com/cli/ "AWS CLI")

### Motivation
It is not an easy thing to login to ECS container of a desired ECS service name, because we need complicated steps to look up which EC2 instance is running specific ECS container. I was so frustrated that I wrote this script.

<br />
***
<br />

## <a name="item2"></a>shell/command_bookmarks.sh
command_bookmarks.sh adds command bookmark functionality to your console.

Bookmarks are saved at ~/.commandBookmarks.

### Demo
It is helpful to bookmark frequently repeated but difficult-to-type commands. 
<br />
For example, you can bookmark `docker stop $(docker ps --filter name=test* -q)` as following.
```
cmdbm add 'docker stop $(docker ps --filter name=test* -q)'
cmdbm ls
> 3: docker stop $(docker ps --filter name=test* -q)
cmdbm run 3
```

### Installation
```
brew tap suhirotaka/utility
brew install cmdbm
```

### Usage
```
Usage: cmdbm [<action>] [<options>]

Actions:
  add <command>     Add command to bookmark
  ls                List bookmarks with their IDs
  edit              Edit bookmarks
  rm <ID>           Delete a bookmark of the specified ID looked up by "ls" action
  run <ID>          Run a command of the specified ID looked up by "ls" action

Options:
  --help     Print this
  --version  Show version
```

<br />
***
<br />

## <a name="item3"></a>aws_lambda/stopEc2Instance.js
stopEc2Instance.js is node script which stops EC2 instance of a desired tag name.

### Usage
You can refresh EC2 instances by following steps.

1. Configure constants

   ```
   const INSTANCE_TAG_NAME = '__YOUR_INSTANCE_TAG_NAME__'; // Set instance's tag name which you want to stop
   const AWS_REGION = 'ap-northeast-1'; // Set your aws region
   const INSTANCE_MIN_COUNT = 0; // Do not stop instance if count of instances of the desired tag name becomes below this value
   ```
2. Set to run stopEc2Instance.js on AWS Lambda
3. Set instance's auto scaling more than 1

### Sytem dependencies
- node
- [AWS SDK for JavaScript](https://www.npmjs.com/package/aws-sdk "AWS SDK for JavaScript")

### Motivation
I found it may cause problems to keep EC2 instance running for a long time because of disk space shortage. It is good manner to refresh EC2 instance periodically for stable server operation.

<br />
***
<br />

## <a name="item4"></a>cloudfront_signed_cookie
cloudfront_signed_cookie contains scripts to use CloudFront's signed cookie.

### Usage
1. Edit signature/policy.json to set domain name, expiration time, etc.
2. Get base64 encoded policy and signature by running signature/get_policy.sh and signature/get_signature.sh
3. Set generated policy and signature to viewer's web browsers. The html in web_example demonstorates how you can do that.

[I wrote an article for detail.](http://qiita.com/suhirotaka/items/514a9e246779dc1b9489 "AWS CloudFront 署名付きcookieの作り方")

<br />
***
<br />

## <a name="item5"></a>ruby/mdfile_link_elasticsearch
mdfile_link_elasticsearch.rb runs Elasticsearch on linked URLs in a markdown format file.

### Usage
1. Run `bunlde install`
2. Create a markdown file as source.md on which Elasticsearch is run
3. Set created file name to MD_FILENAME in mdfile_link_elasticsearch.rb 
4. Run `ruby mdfile_link_elasticsearch.rb <query>`

### System dependencies
- ruby
- [elasticsearch gem](https://github.com/elastic/elasticsearch-ruby "elasticsearch gem")
