```bash
#!/bin/bash

set -euo pipefail

#==========================================================
# Jenkins LTS Installation Script
# Official Jenkins Repository - 2026
#
# Supported:
#   Ubuntu / Debian-based systems
#
# Java:
#   OpenJDK 21 Full JDK
#
# Jenkins:
#   Long Term Support (LTS)
#==========================================================

JENKINS_PORT=8080
JENKINS_REPO="https://pkg.jenkins.io/debian-stable"
JENKINS_KEY_URL="${JENKINS_REPO}/jenkins.io-2026.key"
JENKINS_KEYRING="/usr/share/keyrings/jenkins-keyring.asc"
JENKINS_REPO_FILE="/etc/apt/sources.list.d/jenkins.list"
JENKINS_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

echo "=================================================="
echo "        Jenkins LTS Installation"
echo "=================================================="

#==========================================================
# STEP 0: Verify Operating System
#==========================================================

echo ""
echo "🔍 Checking operating system..."

if [ ! -f /etc/os-release ]; then
    echo "❌ Cannot determine operating system."
    exit 1
fi

source /etc/os-release

case "${ID}" in
    ubuntu|debian)
        echo "✅ Detected: ${PRETTY_NAME}"
        ;;
    *)
        echo "❌ Unsupported operating system: ${PRETTY_NAME}"
        echo "This script supports Ubuntu and Debian."
        exit 1
        ;;
esac

#==========================================================
# STEP 1: Update System
#==========================================================

echo ""
echo "🔄 Updating package index..."

sudo apt update

#==========================================================
# STEP 2: Install Full OpenJDK 21
#==========================================================

echo ""
echo "☕ Installing OpenJDK 21 Full JDK..."

sudo apt install -y fontconfig openjdk-21-jdk

echo ""
echo "✅ Java Version:"
java -version

echo ""
echo "✅ Java Compiler:"
javac -version

#==========================================================
# STEP 3: Check Jenkins Port
#==========================================================

echo ""
echo "🔍 Checking Jenkins port ${JENKINS_PORT}..."

if command -v ss >/dev/null 2>&1; then

    if sudo ss -ltnp | grep -q ":${JENKINS_PORT} "; then

        echo "⚠️ Port ${JENKINS_PORT} is already in use."
        echo ""

        sudo ss -ltnp | grep ":${JENKINS_PORT} " || true

        echo ""
        echo "❌ Jenkins cannot use port ${JENKINS_PORT}."
        echo "Stop the process using this port or configure Jenkins"
        echo "to use a different port before continuing."

        exit 1

    else

        echo "✅ Port ${JENKINS_PORT} is available."

    fi

fi

#==========================================================
# STEP 4: Configure Jenkins LTS Repository
#==========================================================

echo ""
echo "📦 Configuring Jenkins LTS repository..."

sudo mkdir -p /usr/share/keyrings

echo "🔑 Installing Jenkins repository signing key..."

sudo wget -q -O "${JENKINS_KEYRING}" \
    "${JENKINS_KEY_URL}"

sudo chmod 644 "${JENKINS_KEYRING}"

echo "📋 Adding Jenkins LTS repository..."

echo "deb [signed-by=${JENKINS_KEYRING}] ${JENKINS_REPO} binary/" | \
    sudo tee "${JENKINS_REPO_FILE}" > /dev/null

#==========================================================
# STEP 5: Update Repository Information
#==========================================================

echo ""
echo "🔄 Updating package index with Jenkins repository..."

sudo apt update

#==========================================================
# STEP 6: Install Jenkins
#==========================================================

echo ""
echo "📥 Installing Jenkins LTS..."

sudo apt install -y jenkins

#==========================================================
# STEP 7: Enable & Start Jenkins
#==========================================================

echo ""
echo "🚀 Enabling and starting Jenkins..."

sudo systemctl daemon-reload
sudo systemctl enable --now jenkins

#==========================================================
# STEP 8: Verify Jenkins Service
#==========================================================

echo ""
echo "🔍 Checking Jenkins service..."

sleep 5

if systemctl is-active --quiet jenkins; then

    echo "✅ Jenkins service is running."

else

    echo "❌ Jenkins failed to start."
    echo ""

    echo "=================================================="
    echo "        Jenkins Error Logs"
    echo "=================================================="

    sudo journalctl -u jenkins -n 50 --no-pager

    echo ""
    echo "=================================================="
    echo "        Jenkins Service Status"
    echo "=================================================="

    sudo systemctl --no-pager --full status jenkins || true

    exit 1

fi

#==========================================================
# STEP 9: Configure Firewall (Optional)
#==========================================================

echo ""
echo "🛡 Checking firewall configuration..."

if command -v ufw >/dev/null 2>&1; then

    if sudo ufw status | grep -q "Status: active"; then

        echo "🔓 Opening TCP port ${JENKINS_PORT}..."

        sudo ufw allow "${JENKINS_PORT}/tcp"

        echo "✅ Firewall rule configured."

    else

        echo "ℹ️ UFW is installed but inactive."
        echo "No firewall rule was added."

    fi

else

    echo "ℹ️ UFW is not installed."
    echo "Skipping firewall configuration."

fi

#==========================================================
# STEP 10: Jenkins Version
#==========================================================

echo ""
echo "=================================================="
echo "        Jenkins Version"
echo "=================================================="

if command -v jenkins >/dev/null 2>&1; then

    jenkins --version

else

    dpkg-query -W -f='${Package} ${Version}\n' jenkins 2>/dev/null || true

fi

#==========================================================
# STEP 11: Determine Server IP
#==========================================================

SERVER_IP=""

if command -v hostname >/dev/null 2>&1; then

    SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

fi

#==========================================================
# STEP 12: Wait for Initial Admin Password
#==========================================================

echo ""
echo "🔑 Checking for Jenkins initial admin password..."

PASSWORD_FOUND=false

for i in {1..12}; do

    if [ -f "${JENKINS_PASSWORD_FILE}" ]; then

        PASSWORD_FOUND=true
        break

    fi

    sleep 2

done

#==========================================================
# STEP 13: Installation Summary
#==========================================================

echo ""
echo "=================================================="
echo "     Jenkins LTS Installation Completed"
echo "=================================================="

echo ""
echo "🌐 Access Jenkins"

echo "Local : http://localhost:${JENKINS_PORT}"

if [ -n "${SERVER_IP}" ]; then
    echo "Remote: http://${SERVER_IP}:${JENKINS_PORT}"
fi

echo ""

if [ "${PASSWORD_FOUND}" = true ]; then

    echo "🔑 Initial Admin Password:"
    echo ""
    sudo cat "${JENKINS_PASSWORD_FILE}"
    echo ""

else

    echo "⚠️ Initial admin password is not available yet."
    echo ""
    echo "Run:"
    echo "sudo cat ${JENKINS_PASSWORD_FILE}"

fi

#==========================================================
# STEP 14: Java Environment
#==========================================================

echo ""
echo "=================================================="
echo "        Java Environment"
echo "=================================================="

echo "JAVA:"
java -version

echo ""
echo "JAVAC:"
javac -version

echo ""
echo "JAVA_HOME:"
if command -v readlink >/dev/null 2>&1; then
    JAVA_BIN=$(readlink -f "$(command -v java)")
    JAVA_HOME_PATH=$(dirname "$(dirname "${JAVA_BIN}")")
    echo "${JAVA_HOME_PATH}"
fi

#==========================================================
# STEP 15: Final Service Status
#==========================================================

echo ""
echo "=================================================="
echo "        Jenkins Service Status"
echo "=================================================="

sudo systemctl --no-pager --full status jenkins

echo ""
echo "=================================================="
echo "        Installation Complete"
echo "=================================================="

echo ""
echo "🎉 Jenkins LTS installation completed successfully!"

echo ""
echo "Next step:"
echo "Open Jenkins in your browser and complete the"
echo "initial setup wizard."

echo ""
echo "For Jenkins logs:"
echo "sudo journalctl -u jenkins -f"

echo ""
```