#!/bin/bash
read -p 'Stack name: ' stackname

aws cloudformation deploy --template-file cloudformation.yml --stack-name \
$stackname --tags Project=ohm-nominatim --region us-east-1 --capabilities CAPABILITY_IAM
