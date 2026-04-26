#!/bin/bash

set -e

#==========================================================
# Jenkins Installation Script (Official + Clean)
#==========================================================

JENKINS_PORT=8080

echo "🔄 Updating system..."
sudo apt update -y

#==========================================================
# STEP 1: Install Java (Required)
#==========================================================
echo "☕ Installing OpenJDK 21..."
sudo apt install -y openjdk-21-jdk

# Verify Java
echo "🔍 Java version:"
java -version

#==========================================================
# STEP 2: Add Jenkins Repository & Key
#==========================================================
echo "📦 Adding Jenkins repository..."

sudo mkdir -p /etc/apt/keyrings

# Add key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add repo
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

#==========================================================
# STEP 3: Install Jenkins
#==========================================================
echo "📥 Installing Jenkins..."
sudo apt update -y
sudo apt install -y jenkins

#==========================================================
# STEP 4: Start and Enable Jenkins
#==========================================================
echo "🚀 Starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

#==========================================================
# STEP 5: Configure Firewall (Optional)
#==========================================================
echo "🛡 Opening port ${JENKINS_PORT}..."
sudo ufw allow ${JENKINS_PORT} || true

#==========================================================
# STEP 6: Status & Access Info
#==========================================================
echo "✅ Jenkins Status:"
sudo systemctl is-active jenkins

echo ""
echo "🌐 Access Jenkins at:"
echo "http://localhost:${JENKINS_PORT}"

echo ""
echo "🔑 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo ""
echo "🎉 Jenkins installation completed!"