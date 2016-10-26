#!/bin/bash

PRIVATE_KEY_FILE=~/.ssh/ecs_development.pem

service_name=$1
if [ -z "$1" ]; then
  echo "Please input service name."
  exit 1
fi

task_definition=$(aws ecs describe-services --service $service_name | jq '.services[].taskDefinition')
echo Set task definition to $task_definition

task_arns=$(aws ecs list-tasks --cluster default | jq '.taskArns[]')
task_ids=$(echo $task_arns | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/g')
tasks_json=$(aws ecs describe-tasks --cluster default --tasks $task_ids | jq .tasks)
tasks_length=$(echo $tasks_json | jq length)
for i in $( seq 0 $(($tasks_length - 1)) ); do
  task_json=$(echo $tasks_json | jq .[$i])
  if [ $task_definition = $(echo $task_json | jq .taskDefinitionArn) ]; then
    container_instance_arn=$(echo $task_json | jq .containerInstanceArn)
    break
  fi
done
echo Set container instance arn to $container_instance_arn

container_instance_id=$(echo $container_instance_arn | sed -e 's/"[^"\/]*\/\([^"\/]*\)"/\1/g')
ec2_instance_id=$(aws ecs describe-container-instances --cluster default --container-instances $container_instance_id | jq .containerInstances[].ec2InstanceId | sed -e 's/"//g')

public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instance_id | jq .Reservations[].Instances[].PublicIpAddress | sed -e 's/"//g')

# login with SSH
echo Successfully get public IP, SSH to $public_ip ...
ssh -i $PRIVATE_KEY_FILE ec2-user@$public_ip
