#!/bin/bash
component=$1
environment=$2
yum install python3.11-devel python3.11-pip -y
pip3.11 install ansible botocore boto3 #We can install ansible through pip 
# botocore is aws python packages and if we need to connect  through api's we need these packages
ansible-pull -U https://github.com/Chai66/roboshop-ansible-roles-tf.git -e component=$component -e env=$environment main-tf.yaml
# It will pull from the GIT and run all the roles,
 