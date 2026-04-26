#!/bin/bash

cd /opt/

# Download SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip

# Install unzip if not installed
sudo apt update -y
sudo apt install unzip -y

# Extract SonarQube
unzip sonarqube-8.9.6.50800.zip

# Install OpenJDK 17 (standard Ubuntu JDK)
sudo apt install openjdk-17-jdk -y

# Create sonar user
sudo useradd sonar

# Permissions
sudo chown sonar:sonar sonarqube-8.9.6.50800 -R
sudo chmod 777 sonarqube-8.9.6.50800 -R

# Switch to sonar user
sudo su - sonar

# NOTE: Run this manually after switching user
# sh /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start
# echo "user=admin & password=admin"
