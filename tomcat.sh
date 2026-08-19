#!/bin/bash

set -e

# ==========================================
# Variables
# ==========================================
TOMCAT_VERSION="11.0.21"
TOMCAT_DIR="/opt/apache-tomcat-${TOMCAT_VERSION}"
TOMCAT_TAR="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-11/v${TOMCAT_VERSION}/bin/${TOMCAT_TAR}"

TOMCAT_USER="tomcat"
TOMCAT_PASSWORD="root123456"

# ==========================================
# Update packages
# ==========================================
sudo apt update -y

# ==========================================
# Install Java 21
# ==========================================
sudo apt install openjdk-21-jdk wget -y

echo "Java version:"
java -version

# ==========================================
# Download Tomcat
# ==========================================
cd /opt

if [ ! -f "${TOMCAT_TAR}" ]; then
    echo "Downloading Tomcat ${TOMCAT_VERSION}..."
    sudo wget "${TOMCAT_URL}"
else
    echo "Tomcat archive already exists."
fi

# ==========================================
# Extract Tomcat
# ==========================================
if [ ! -d "${TOMCAT_DIR}" ]; then
    echo "Extracting Tomcat..."
    sudo tar -xzf "${TOMCAT_TAR}"
else
    echo "Tomcat directory already exists."
fi

# ==========================================
# Create Tomcat user
# ==========================================
if ! id "${TOMCAT_USER}" >/dev/null 2>&1; then
    sudo useradd \
        --system \
        --home "${TOMCAT_DIR}" \
        --shell /bin/false \
        "${TOMCAT_USER}"
fi

# ==========================================
# Set permissions
# ==========================================
sudo chown -R "${TOMCAT_USER}:${TOMCAT_USER}" "${TOMCAT_DIR}"

sudo chmod +x "${TOMCAT_DIR}/bin/"*.sh

# ==========================================
# Configure tomcat-users.xml
# ==========================================
echo "Configuring Tomcat users..."

sudo cp \
"${TOMCAT_DIR}/conf/tomcat-users.xml" \
"${TOMCAT_DIR}/conf/tomcat-users.xml.bak"

# Remove previously added manager entries
sudo sed -i '/<role rolename="manager-gui"\/>/d' \
"${TOMCAT_DIR}/conf/tomcat-users.xml"

sudo sed -i '/<role rolename="manager-script"\/>/d' \
"${TOMCAT_DIR}/conf/tomcat-users.xml"

sudo sed -i '/<user username="tomcat"/d' \
"${TOMCAT_DIR}/conf/tomcat-users.xml"

# Add manager roles and user before closing tag
sudo sed -i '/<\/tomcat-users>/i\
    <role rolename="manager-gui"/>\
    <role rolename="manager-script"/>\
    <user username="tomcat" password="root123456" roles="manager-gui,manager-script"/>' \
"${TOMCAT_DIR}/conf/tomcat-users.xml"

# ==========================================
# Configure Manager application
# Allow remote access
# ==========================================
echo "Configuring Tomcat Manager remote access..."

sudo cp \
"${TOMCAT_DIR}/webapps/manager/META-INF/context.xml" \
"${TOMCAT_DIR}/webapps/manager/META-INF/context.xml.bak"

# Remove RemoteAddrValve restriction
sudo sed -i '/RemoteAddrValve/d' \
"${TOMCAT_DIR}/webapps/manager/META-INF/context.xml"

# Remove RemoteCIDRValve if present
sudo sed -i '/RemoteCIDRValve/d' \
"${TOMCAT_DIR}/webapps/manager/META-INF/context.xml"

# ==========================================
# Set ownership again
# ==========================================
sudo chown -R "${TOMCAT_USER}:${TOMCAT_USER}" "${TOMCAT_DIR}"

# ==========================================
# Stop existing Tomcat if running
# ==========================================
if [ -f "${TOMCAT_DIR}/bin/shutdown.sh" ]; then
    sudo -u "${TOMCAT_USER}" "${TOMCAT_DIR}/bin/shutdown.sh" || true
fi

sleep 3

# ==========================================
# Start Tomcat
# ==========================================
echo "Starting Tomcat..."

sudo -u "${TOMCAT_USER}" \
"${TOMCAT_DIR}/bin/startup.sh"

# ==========================================
# Wait for Tomcat
# ==========================================
sleep 5

# ==========================================
# Check Tomcat
# ==========================================
echo ""
echo "=========================================="
echo "Tomcat installation completed"
echo "=========================================="

echo "Tomcat version:"
sudo -u "${TOMCAT_USER}" \
"${TOMCAT_DIR}/bin/version.sh"

echo ""
echo "Tomcat URL:"
echo "http://YOUR_SERVER_IP:8080"

echo ""
echo "Tomcat Manager:"
echo "http://YOUR_SERVER_IP:8080/manager/html"

echo ""
echo "Username: ${TOMCAT_USER}"
echo "Password: ${TOMCAT_PASSWORD}"

echo ""
echo "Checking Tomcat port..."

if sudo ss -lntp | grep -q ":8080"; then
    echo "Tomcat is listening on port 8080."
else
    echo "WARNING: Tomcat is not listening on port 8080."
fi

echo "=========================================="