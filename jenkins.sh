#!/bin/bash

set -e

#==========================================================
# Jenkins Installation Script (Ubuntu / Debian)
# Installs: Git, Maven, Java 21, Jenkins
#==========================================================

# Variables
JENKINS_PORT=8080
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo localhost)
JENKINS_URL="http://${PUBLIC_IP}:${JENKINS_PORT}"
JAVA_VERSION="21"

#==========================================================
# STEP 1: Install Git, Maven, Curl, and unzip
#==========================================================
echo "🔧 Installing Git, Maven, Curl, and unzip..."
sudo apt update -y
sudo apt install -y git maven curl unzip

#==========================================================
# STEP 2: Install Java $JAVA_VERSION
#==========================================================
echo "☕ Installing Java $JAVA_VERSION..."
sudo apt update -y
sudo apt install -y openjdk-${JAVA_VERSION}-jdk fontconfig

# Verify Java installation
echo "💻 Verifying Java installation..."
java -version
javac -version

# Set JAVA_HOME
JAVA_HOME_PATH=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "export JAVA_HOME=${JAVA_HOME_PATH}" | sudo tee /etc/profile.d/java.sh
source /etc/profile.d/java.sh

echo "✅ JAVA_HOME set to: $JAVA_HOME"

#==========================================================
# STEP 3: Add Jenkins Repository
#==========================================================
echo "📦 Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

#==========================================================
# STEP 4: Install Jenkins
#==========================================================
echo "📥 Installing Jenkins..."
sudo apt update -y
sudo apt install -y jenkins

#==========================================================
# STEP 5: Start Jenkins
#==========================================================
echo "🚀 Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

#==========================================================
# STEP 6: Configure Firewall (optional)
#==========================================================
echo "🛡 Configuring firewall to allow port ${JENKINS_PORT}..."
sudo ufw allow ${JENKINS_PORT} || true

#==========================================================
# STEP 7: Display Jenkins Status and Initial Admin Password
#==========================================================
echo "✅ Jenkins service status:"
sudo systemctl is-active jenkins

echo "➡ Jenkins URL: ${JENKINS_URL}"
echo "🔑 Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

#==========================================================
# STEP 8: Optional Notes
#==========================================================
echo "💡 Notes:"
echo "- Visit the URL above to unlock Jenkins and install recommended plugins."
echo "- Git and Maven are installed for building Java projects."
echo "- Java $JAVA_VERSION is installed and JAVA_HOME is set."
