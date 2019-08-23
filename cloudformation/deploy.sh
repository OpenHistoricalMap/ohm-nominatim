#!/bin/bash
read -p 'Stack name: ' stackname
read -sp 'DB password: ' dbpassword

aws cloudformation deploy --template-file cloudformation.yml --stack-name \
$stackname --tags Project=ohm-nominatim --region us-east-1 --capabilities CAPABILITY_IAM \
--parameter-overrides DBPassword=$dbpassword
