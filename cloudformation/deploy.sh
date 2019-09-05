#!/bin/bash
read -p 'Stack name: ' stackname
read -sp 'DB password: ' dbpassword
read -p 'DB host: ' dbhost
read -p 'DB port: ' dbport

aws cloudformation deploy --template-file cloudformation.yml --stack-name \
$stackname --tags Project=ohm-nominatim --region us-east-1 --capabilities CAPABILITY_IAM \
--parameter-overrides DBPassword=$dbpassword PGHost=$dbhost PGPort=$dbport
