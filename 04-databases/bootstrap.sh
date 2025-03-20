# #!/bin/bash
component=$1
environment=$2
# yum install python3.11-devel python3.11-pip -y
# pip3.11 install ansible botocore boto3 #We can install ansible through pip 
# Set Python 3.11 as the default python and pip
yum module enable python3.9 -y
yum install -y python3.11 python3.11-devel python3.11-pip

alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11
alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.11

# Verify the Python version
python3 --version
pip3 --version

# Upgrade pip and install required Python libraries
python3 -m pip install --upgrade pip
python3 -m pip install ansible botocore boto3

# # botocore is aws python packages and if we need to connect  through api's we need these packages
ansible-pull -U https://github.com/Chai66/roboshop-ansible-roles-tf.git -e component=$component -e env=$environment main-tf.yaml
# It will pull from the GIT and run all the roles,
 


 #!/bin/bash

# # Arguments for the script
# component=$1
# environment=$2  # Don't use env here

# # Install EPEL and Remi repository for the latest Python
# yum install -y epel-release
# yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

# # Enable Remi repository and install Python 3.11 and related packages
# yum module enable python39 -y
# yum install -y python3.11 python3.11-devel python3.11-pip

# # Set Python 3.11 as the default python and pip
# alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11
# alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.11

# # Verify the Python version
# python3 --version
# pip3 --version

# # Upgrade pip and install required Python libraries
# python3 -m pip install --upgrade pip
# python3 -m pip install ansible botocore boto3

# # Execute Ansible pull with component and environment
# ansible-pull -U https://github.com/Chai66/roboshop-ansible-roles-tf.git -e component=$component -e env=$environment main-tf.yaml
  