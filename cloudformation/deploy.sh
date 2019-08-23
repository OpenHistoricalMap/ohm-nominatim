#!/bin/bash
aws cloudformation deploy --template-file cloudformation.yml --stack-name \
ohm-nominatim --tags Project=ohm-nominatim --region us-east-1 --capabilities CAPABILITY_IAM
