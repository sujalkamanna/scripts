#!/bin/bash

set -e

#==========================================================
# STEP-1: Install Git and Maven
#==========================================================
echo "🔧 Installing Git and Maven..."
sudo apt update
sudo apt install -y git maven curl

#==========================================================
# STEP-2: Add Jenkins Repository
#==========================================================
echo "📦 Adding Jenkins repository..."

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

#==========================================================
# STEP-3: Install Java 21 and Jenkins
#==========================================================
echo "☕ Installing Java 21 and Jenkins..."

sudo apt update
sudo apt install -y fontconfig openjdk-21-jdk jenkins

#==========================================================
# STEP-4: Start Jenkins
#==========================================================
echo "🚀 Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

#==========================================================
# STEP-5: Firewall (optional but recommended)
#==========================================================
sudo ufw allow 8080 || true

#==========================================================
# STEP-6: Jenkins Status & Password
#==========================================================
echo "✅ Jenkins is running:"
sudo systemctl is-active jenkins

echo "➡ URL: http://<your-server-ip>:8080"
echo "🔑 Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
