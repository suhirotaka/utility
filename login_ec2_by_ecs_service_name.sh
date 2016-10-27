#!/bin/bash

DEFAULT_PRIVATE_KEY_FILE=~/.ssh/ecs_development.pem

# Show command line help
show_usage() {
  echo "Usage: $0 [-c] [-f private_key_file] ecs_service_name"
}

# Get options
while getopts f:ch OPT
do
  case $OPT in
    f)  PRIVATE_KEY_FILE=$OPTARG
        ;;
    c)  CONTAINER_LOGIN=true
        ;;
    h)  show_usage
        exit 0
        ;;
    \?) show_usage
        exit 1
        ;;
  esac
done

shift $((OPTIND - 1))
ECS_SERVICE_NAME=$1

if [ -z "${PRIVATE_KEY_FILE+a}" ]; then
  PRIVATE_KEY_FILE=$DEFAULT_PRIVATE_KEY_FILE
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

task_arns=$(aws ecs list-tasks --cluster default | jq '.taskArns[]')
task_ids=$(echo $task_arns | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/g')
tasks_json=$(aws ecs describe-tasks --cluster default --tasks $task_ids | jq .tasks)
tasks_length=$(echo $tasks_json | jq length)
for i in $( seq 0 $(($tasks_length - 1)) ); do
  task_json=$(echo $tasks_json | jq .[$i])
  if [ $task_definition = $(echo $task_json | jq .taskDefinitionArn | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/') ]; then
    container_instance_arn=$(echo $task_json | jq .containerInstanceArn)
    break
  fi
done

container_instance_id=$(echo $container_instance_arn | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/g')
ec2_instance_id=$(aws ecs describe-container-instances --cluster default --container-instances $container_instance_id | jq .containerInstances[].ec2InstanceId | sed -e 's/"//g')

public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instance_id | jq .Reservations[].Instances[].PublicIpAddress | sed -e 's/"//g')

# SSH to EC2 instance
container_type=$(echo $task_definition | sed -e 's/.*-\([^\-\:]*\):[0-9]*/\1/')
container_name="ecs-$(echo $task_definition | sed -e 's/:/-/')-${container_type}"
docker_command="docker exec -it \$(docker ps --filter name=${container_name} -q) bash"
if [ -n "${CONTAINER_LOGIN+a}" -a $CONTAINER_LOGIN ]; then
  echo SSH to container $container_name@$public_ip ...
  ssh -t -i $PRIVATE_KEY_FILE ec2-user@$public_ip $docker_command
else
  echo SSH to $public_ip ...
  ssh -i $PRIVATE_KEY_FILE ec2-user@$public_ip
fi
