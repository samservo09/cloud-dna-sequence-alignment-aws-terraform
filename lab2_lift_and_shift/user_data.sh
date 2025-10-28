#!/bin/bash
# user_data.sh for Ubuntu

# Short delay to allow network/apt initialization
sleep 20

# Update package lists and upgrade existing packages
apt-get update -y
apt-get upgrade -y

# Install Python 3, pip, git, and EMBOSS
apt-get install -y python3-pip git emboss

# Install Boto3 Python library
pip3 install boto3

# (Optional) Add lines here to automatically clone your Git repository if desired
# cd /home/ubuntu
# git clone https://github.com/your-username/your-repo-name.git
# chown -R ubuntu:ubuntu /home/ubuntu/your-repo-name