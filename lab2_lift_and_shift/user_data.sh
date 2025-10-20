#!/bin/bash
sudo yum update -y
sudo yum install -y python3-pip
pip3 install boto3

# Install MAFFT (example for Amazon Linux)
# This is the key "lift & shift" step for the tool
sudo yum install -y mafft