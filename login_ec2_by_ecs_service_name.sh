#!/bin/bash

service_name=$1
if [ -z "$1" ]; then
  echo "Please input service name."
  exit 1
fi

task_definition=$(aws ecs describe-services --service $service_name | jq '.services[].taskDefinition')
task_arns=$(aws ecs list-tasks --cluster default | jq '.taskArns[]')
task_ids=$(echo $task_arns | sed -e 's/[^"\/]*\///g' | sed -e 's/"//g')

json=$(aws ecs describe-tasks --cluster default --tasks $task_ids | jq .tasks)
len=$(echo $json | jq length)
for i in $( seq 0 $(($len - 1)) ); do
  json2=$(echo $json | jq .[$i])
  
  if [ $task_definition = $(echo $json2 | jq .taskDefinitionArn) ]; then
    container_instance_arn=$(echo $json2 | jq .containerInstanceArn)
  fi
done

container_instance_id=$(echo $container_instance_arn | sed -e 's/[^"\/]*\///g' | sed -e 's/"//g')
ec2_instance_id=$(aws ecs describe-container-instances --cluster default --container-instances $container_instance_id | jq .containerInstances[].ec2InstanceId | sed -e 's/"//g')

public_ip=$(aws ec2 describe-instances --instance-ids $ec2_instance_id | jq .Reservations[].Instances[].PublicIpAddress | sed -e 's/"//g')

# login with SSH
echo SSH to $public_ip ...
ssh -i ~/.ssh/ecs_development.pem ec2-user@$public_ip
