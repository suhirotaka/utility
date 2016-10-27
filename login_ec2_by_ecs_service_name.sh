#!/bin/bash

DEFAULT_PRIVATE_KEY_FILE=~/.ssh/ecs_development.pem
DEFAULT_CLUSTER_NAME=default

# Show usage
usage() {
  cat <<__EOS__
Usage:
  $(basename $0) [-f private_key_file_name] [-c] [-d] ecs_service_name

Options:
  -f private key file name
  -c ECS cluster name
  -d directly login to container
  -h print this
__EOS__
}

# Get options
if [ $# -eq 0 ]; then
  usage
  exit 0
fi

while getopts f:cdh OPT
do
  case $OPT in
    f)  PRIVATE_KEY_FILE=$OPTARG
        ;;
    c)  CLUSTER_NAME=$OPTARG
        ;;
    d)  CONTAINER_LOGIN=1
        ;;
    h)  usage
        exit 0
        ;;
    \?) usage
        exit 1
        ;;
  esac
done

shift $((OPTIND - 1))
ECS_SERVICE_NAME=$1

if [ -z "${PRIVATE_KEY_FILE+a}" ]; then
  PRIVATE_KEY_FILE=$DEFAULT_PRIVATE_KEY_FILE
fi

if [ -z "${CLUSTER_NAME+a}" ]; then
  CLUSTER_NAME=$DEFAULT_CLUSTER_NAME
fi

# Check environment
if [ -z "$1" ]; then
  echo "Please input service name."
  exit 1
fi

if ! type "jq" > /dev/null 2>&1; then
  echo "Please install jq."
  exit 1
fi

if [ ! -e $PRIVATE_KEY_FILE ]; then
  echo "Private key file not found."
  exit 1
fi

# Get public IP from ecs service name
echo Start to process login ...

task_definition_arn=$(aws ecs describe-services --service $ECS_SERVICE_NAME | jq '.services[].taskDefinition')
task_definition=$(echo $task_definition_arn | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/')

task_arns=$(aws ecs list-tasks --cluster $CLUSTER_NAME | jq '.taskArns[]')
task_ids=$(echo $task_arns | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/g')
tasks_json=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $task_ids | jq .tasks)
tasks_length=$(echo $tasks_json | jq length)
for i in $( seq 0 $(($tasks_length - 1)) ); do
  task_json=$(echo $tasks_json | jq .[$i])
  if [ $task_definition = $(echo $task_json | jq .taskDefinitionArn | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/') ]; then
    container_instance_arn=$(echo $task_json | jq .containerInstanceArn)
    break
  fi
done

container_instance_id=$(echo $container_instance_arn | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/g')
ec2_instance_id=$(aws ecs describe-container-instances --cluster $CLUSTER_NAME --container-instances $container_instance_id | jq .containerInstances[].ec2InstanceId | sed -e 's/"//g')

public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instance_id | jq .Reservations[].Instances[].PublicIpAddress | sed -e 's/"//g')

# SSH to EC2 instance
container_type=$(echo $task_definition | sed -e 's/.*-\([^\-\:]*\):[0-9]*/\1/')
container_name="ecs-$(echo $task_definition | sed -e 's/:/-/')-${container_type}"
docker_command="docker exec -it \$(docker ps --filter name=${container_name} -q) bash"
if [ -n "${CONTAINER_LOGIN+a}" -a $CONTAINER_LOGIN -eq 1 ]; then
  echo SSH to container $container_name@$public_ip ...
  ssh -t -i $PRIVATE_KEY_FILE ec2-user@$public_ip $docker_command
else
  echo SSH to $public_ip ...
  ssh -i $PRIVATE_KEY_FILE ec2-user@$public_ip
fi
