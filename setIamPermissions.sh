#!/bin/bash
export envIds=`aws cloud9 list-environments --output text --query environmentIds`
for envId in $envIds; do
    export envName=`aws cloud9 describe-environments --environment-ids $envId --output text --query 'environments[*].name'`
    if [ "$envName" == "$1" ]
    then
        echo $envId
        aws cloud9 update-environment --environment-id $envId --managed-credentials-action DISABLE
    fi
done
export cloud9InstanceId=`aws ec2 describe-instances --output text --filters Name=tag:aws:cloud9:environment,Values=$envId --query 'Reservations[*].Instances[*].InstanceId'`
aws ec2 associate-iam-instance-profile --instance-id $cloud9InstanceId --iam-instance-profile Name=Cloud9InstanceProfile-$1