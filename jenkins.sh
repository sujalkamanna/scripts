#!/bin/bash

#==========================================================
# STEP-1: Installing Git and Maven   (yum install git maven -y)
#==========================================================
echo "🔧 Installing Git and Maven..."
sudo apt update -y
sudo apt install -y git maven

#==========================================================
# STEP-2: Jenkins Repository Setup (jenkins.io repo)
# (wget -O /etc/yum.repos.d/jenkins.repo ... rpm --import ...)
#==========================================================
echo "📦 Adding Jenkins repository..."

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

#==========================================================
# STEP-3: Install Java 21 and Jenkins
# (yum install java-21-amazon-corretto && yum install jenkins -y)
#==========================================================
echo "☕ Installing Java 21 + Jenkins..."

sudo apt update -y
sudo apt install -y fontconfig openjdk-21-jdk
sudo apt install -y jenkins

# Optional: Increase tmp size for large builds
# sudo mount -o remount,size=2G /tmp

#==========================================================
# STEP-4: Start and check Jenkins status
# (systemctl start jenkins.service / systemctl status jenkins.service)
#==========================================================
echo "🚀 Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager

#==========================================================
# STEP-5: Auto-Start Jenkins
# (chkconfig jenkins on → systemctl enable jenkins)
#==========================================================
echo "🔒 Enabling Jenkins auto-start at boot..."
sudo systemctl enable jenkins

echo "✅ Jenkins installation completed successfully!"
echo "➡ URL:  http://<your-server-ip>:8080"
echo "🔑 Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
