#!/bin/bash

set -e

SONAR_VERSION="9.9.4.87374"
SONAR_DIR="/opt/sonarqube"
SONAR_USER="sonar"

echo "🔄 Updating system..."
sudo apt update -y

#==========================================================
# STEP 1: Install dependencies
#==========================================================
echo "📦 Installing dependencies..."
sudo apt install -y unzip wget openjdk-17-jdk

#==========================================================
# STEP 2: Download SonarQube
#==========================================================
cd /opt

echo "⬇️ Downloading SonarQube ${SONAR_VERSION}..."
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip

#==========================================================
# STEP 3: Extract and setup
#==========================================================
echo "📂 Extracting SonarQube..."
sudo unzip sonarqube-${SONAR_VERSION}.zip
sudo mv sonarqube-${SONAR_VERSION} ${SONAR_DIR}

#==========================================================
# STEP 4: Create sonar user
#==========================================================
echo "👤 Creating sonar user..."
sudo useradd -r -m -U -d ${SONAR_DIR} -s /bin/bash ${SONAR_USER} || true

# Set ownership
sudo chown -R ${SONAR_USER}:${SONAR_USER} ${SONAR_DIR}

#==========================================================
# STEP 5: System tuning (required)
#==========================================================
echo "⚙️ Configuring system limits..."

sudo bash -c 'cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=262144
fs.file-max=65536
EOF'

sudo sysctl -p

sudo bash -c 'cat >> /etc/security/limits.conf <<EOF
sonar   -   nofile   65536
sonar   -   nproc    4096
EOF'

#==========================================================
# STEP 6: Create systemd service
#==========================================================
echo "🛠 Creating SonarQube service..."

sudo bash -c "cat > /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking

ExecStart=${SONAR_DIR}/bin/linux-x86-64/sonar.sh start
ExecStop=${SONAR_DIR}/bin/linux-x86-64/sonar.sh stop

User=${SONAR_USER}
Group=${SONAR_USER}
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF"

#==========================================================
# STEP 7: Start SonarQube
#==========================================================
echo "🚀 Starting SonarQube..."

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

#==========================================================
# STEP 8: Status
#==========================================================
echo "✅ SonarQube status:"
sudo systemctl status sonarqube --no-pager

echo ""
echo "🌐 Access SonarQube at: http://localhost:9000"
echo "🔑 Default login: admin / admin"