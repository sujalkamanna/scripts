#!/bin/bash

set -e

# ==========================================================
# Jenkins LTS + OpenJDK 21
# Ubuntu 24.04 / Ubuntu 26.04
# ==========================================================

JENKINS_PORT=8080
JENKINS_PASSWORD="/var/lib/jenkins/secrets/initialAdminPassword"

echo "=========================================="
echo " Jenkins LTS Installation"
echo " Ubuntu 24.04 / 26.04"
echo " OpenJDK 21 Full JDK"
echo "=========================================="

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

# ----------------------------------------------------------
# STEP 1: Update package index
# ----------------------------------------------------------

echo ""
echo "Updating APT..."

apt update

# ----------------------------------------------------------
# STEP 2: Install OpenJDK 21 Full JDK
# ----------------------------------------------------------

echo ""
echo "Installing OpenJDK 21 Full JDK..."

apt install -y \
    fontconfig \
    openjdk-21-jdk \
    wget \
    ca-certificates

echo ""
echo "Java version:"
java -version

echo ""
echo "Javac version:"
javac -version

# ----------------------------------------------------------
# STEP 3: Jenkins repository
# ----------------------------------------------------------

echo ""
echo "Adding Jenkins LTS repository..."

mkdir -p /etc/apt/keyrings

wget -q -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

# ----------------------------------------------------------
# STEP 4: Install Jenkins
# ----------------------------------------------------------

echo ""
echo "Updating APT with Jenkins repository..."

apt update

echo ""
echo "Installing Jenkins LTS..."

apt install -y jenkins

# ----------------------------------------------------------
# STEP 5: Start Jenkins
# ----------------------------------------------------------

echo ""
echo "Starting Jenkins..."

systemctl enable jenkins
systemctl start jenkins

# ----------------------------------------------------------
# STEP 6: Check Jenkins
# ----------------------------------------------------------

echo ""
echo "Checking Jenkins status..."

sleep 5

if systemctl is-active --quiet jenkins; then
    echo "Jenkins is RUNNING."
else
    echo "ERROR: Jenkins failed to start."
    systemctl status jenkins --no-pager
    exit 1
fi

# ----------------------------------------------------------
# STEP 7: Show Jenkins information
# ----------------------------------------------------------

echo ""
echo "=========================================="
echo " Jenkins Installation Complete"
echo "=========================================="

echo ""
echo "Jenkins status:"
systemctl is-active jenkins

echo ""
echo "Jenkins version:"
dpkg-query -W -f='${Version}\n' jenkins

echo ""
echo "Java version:"
java -version

echo ""
echo "Javac version:"
javac -version

echo ""
echo "Jenkins URL:"
echo "http://YOUR_SERVER_IP:${JENKINS_PORT}"

# ----------------------------------------------------------
# STEP 8: Initial Jenkins password
# ----------------------------------------------------------

echo ""
echo "=========================================="
echo " Jenkins Initial Admin Password"
echo "=========================================="

if [ -f "$JENKINS_PASSWORD" ]; then

    echo ""
    cat "$JENKINS_PASSWORD"
    echo ""

else

    echo ""
    echo "Password file not available yet."
    echo ""
    echo "Run:"
    echo "cat $JENKINS_PASSWORD"

fi

echo ""
echo "=========================================="
echo " Installation Finished"
echo "=========================================="

echo ""
echo "Jenkins logs:"
echo "journalctl -u jenkins -f"