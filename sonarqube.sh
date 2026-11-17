#!/bin/bash

set -Eeuo pipefail

# ==========================================================
# SonarQube Community Build
# Ubuntu 24.04
# Java 21
# PostgreSQL 16
# ==========================================================

SONAR_VERSION="26.8.0.126808"
SONAR_DIR="/opt/sonarqube"
SONAR_USER="sonarqube"

DB_NAME="sonarqube"
DB_USER="sonar"

# CHANGE THIS PASSWORD
DB_PASSWORD="ChangeThisToAStrongPassword"

SONAR_ZIP="/tmp/sonarqube-${SONAR_VERSION}.zip"

SONAR_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip"

# ==========================================================
# ERROR HANDLER
# ==========================================================

error_handler() {
    echo ""
    echo "=================================================="
    echo "❌ INSTALLATION FAILED"
    echo "=================================================="
    echo ""
    echo "Line: ${BASH_LINENO[0]}"
    echo "Command: ${BASH_COMMAND}"
    echo ""

    echo "If SonarQube was already installed, check:"
    echo ""
    echo "sudo systemctl status sonarqube"
    echo "sudo journalctl -u sonarqube -n 100 --no-pager"
    echo "sudo tail -100 ${SONAR_DIR}/logs/sonar.log 2>/dev/null || true"
    echo ""

    exit 1
}

trap error_handler ERR

# ==========================================================
# ROOT CHECK
# ==========================================================

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root:"
    echo ""
    echo "sudo bash sonar.sh"
    exit 1
fi

echo ""
echo "=================================================="
echo " SonarQube Community Build Installation"
echo "=================================================="
echo ""
echo "Version : ${SONAR_VERSION}"
echo "OS      : Ubuntu 24.04"
echo "Java    : 21"
echo "Database: PostgreSQL"
echo ""

# ==========================================================
# STEP 1
# ==========================================================

echo "=================================================="
echo "STEP 1: Updating system"
echo "=================================================="

apt-get update -y

# ==========================================================
# STEP 2
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 2: Installing dependencies"
echo "=================================================="

apt-get install -y \
    openjdk-21-jdk \
    postgresql \
    postgresql-contrib \
    wget \
    curl \
    unzip \
    ca-certificates

# ==========================================================
# STEP 3
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 3: Checking Java"
echo "=================================================="

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

echo "Java version: ${JAVA_VERSION}"

JAVA_MAJOR=$(echo "${JAVA_VERSION}" | cut -d. -f1)

if [ "${JAVA_MAJOR}" != "21" ]; then
    echo "❌ Java 21 is required."
    exit 1
fi

echo "✅ Java 21 detected"

# ==========================================================
# STEP 4
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 4: Starting PostgreSQL"
echo "=================================================="

systemctl enable postgresql
systemctl start postgresql

if ! systemctl is-active --quiet postgresql; then
    echo "❌ PostgreSQL failed to start."
    exit 1
fi

echo "✅ PostgreSQL is running"

# ==========================================================
# STEP 5
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 5: Configuring PostgreSQL"
echo "=================================================="

echo "Creating PostgreSQL user..."

runuser -u postgres -- psql -v ON_ERROR_STOP=1 <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE rolname = '${DB_USER}'
    ) THEN
        CREATE ROLE ${DB_USER}
        LOGIN
        PASSWORD '${DB_PASSWORD}';
    ELSE
        ALTER ROLE ${DB_USER}
        WITH LOGIN
        PASSWORD '${DB_PASSWORD}';
    END IF;
END
\$\$;
EOF

echo "PostgreSQL user configured."

echo "Creating database if it does not exist..."

if runuser -u postgres -- psql -tAc \
    "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1; then

    echo "Database ${DB_NAME} already exists."

else

    runuser -u postgres -- createdb \
        -O "${DB_USER}" \
        "${DB_NAME}"

    echo "Database ${DB_NAME} created."

fi

echo "Setting database owner..."

runuser -u postgres -- psql -v ON_ERROR_STOP=1 <<EOF
ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};
EOF

echo "Testing PostgreSQL connection..."

PGPASSWORD="${DB_PASSWORD}" \
psql \
    -h 127.0.0.1 \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    -c "SELECT version();" >/dev/null

echo "✅ PostgreSQL configured successfully"

# ==========================================================
# STEP 6
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 6: Creating SonarQube user"
echo "=================================================="

if id "${SONAR_USER}" >/dev/null 2>&1; then

    echo "User ${SONAR_USER} already exists."

else

    useradd \
        --system \
        --create-home \
        --home-dir "${SONAR_DIR}" \
        --shell /bin/bash \
        "${SONAR_USER}"

    echo "User ${SONAR_USER} created."

fi

# ==========================================================
# STEP 7
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 7: Checking SonarQube download URL"
echo "=================================================="

echo "URL:"
echo "${SONAR_URL}"
echo ""

HTTP_CODE=$(curl \
    --silent \
    --show-error \
    --output /dev/null \
    --write-out "%{http_code}" \
    --location \
    "${SONAR_URL}" || true)

echo "HTTP status: ${HTTP_CODE}"

if [ "${HTTP_CODE}" != "200" ]; then

    echo ""
    echo "❌ Download URL returned HTTP ${HTTP_CODE}"
    echo ""
    echo "Official download page:"
    echo "https://www.sonarsource.com/products/sonarqube/downloads/"
    exit 1

fi

echo "✅ Download URL is accessible"

# ==========================================================
# STEP 8
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 8: Downloading SonarQube"
echo "=================================================="

rm -f "${SONAR_ZIP}"

curl \
    --fail \
    --location \
    --proto '=https' \
    --tlsv1.2 \
    --output "${SONAR_ZIP}" \
    "${SONAR_URL}"

echo "Download completed."

# ==========================================================
# STEP 9
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 9: Validating ZIP"
echo "=================================================="

if ! unzip -t "${SONAR_ZIP}" >/dev/null 2>&1; then

    echo "❌ ZIP validation failed."

    rm -f "${SONAR_ZIP}"

    exit 1

fi

echo "✅ ZIP is valid"

# ==========================================================
# STEP 10
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 10: Extracting SonarQube"
echo "=================================================="

rm -rf "/opt/sonarqube-${SONAR_VERSION}"

unzip -q \
    "${SONAR_ZIP}" \
    -d /opt

if [ ! -d "/opt/sonarqube-${SONAR_VERSION}" ]; then

    echo "❌ Extraction directory not found."

    exit 1

fi

# Only replace existing installation after successful extraction
rm -rf "${SONAR_DIR}"

mv \
    "/opt/sonarqube-${SONAR_VERSION}" \
    "${SONAR_DIR}"

rm -f "${SONAR_ZIP}"

echo "✅ SonarQube installed at ${SONAR_DIR}"

# ==========================================================
# STEP 11
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 11: Configuring SonarQube"
echo "=================================================="

cat > "${SONAR_DIR}/conf/sonar.properties" <<EOF

sonar.jdbc.username=${DB_USER}
sonar.jdbc.password=${DB_PASSWORD}
sonar.jdbc.url=jdbc:postgresql://127.0.0.1:5432/${DB_NAME}

sonar.web.host=0.0.0.0
sonar.web.port=9000

EOF

echo "✅ SonarQube database configuration created"

# ==========================================================
# STEP 12
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 12: Setting ownership"
echo "=================================================="

chown -R \
    "${SONAR_USER}:${SONAR_USER}" \
    "${SONAR_DIR}"

echo "✅ Ownership configured"

# ==========================================================
# STEP 13
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 13: Configuring kernel parameters"
echo "=================================================="

cat > /etc/sysctl.d/99-sonarqube.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF

sysctl --system

echo "✅ Kernel parameters configured"

# ==========================================================
# STEP 14
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 14: Configuring limits"
echo "=================================================="

cat > /etc/security/limits.d/sonarqube.conf <<EOF
${SONAR_USER} - nofile 131072
${SONAR_USER} - nproc 8192
EOF

echo "✅ Limits configured"

# ==========================================================
# STEP 15
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 15: Creating systemd service"
echo "=================================================="

cat > /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube Server
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=forking

User=${SONAR_USER}
Group=${SONAR_USER}

WorkingDirectory=${SONAR_DIR}

ExecStart=${SONAR_DIR}/bin/linux-x86-64/sonar.sh start
ExecStop=${SONAR_DIR}/bin/linux-x86-64/sonar.sh stop

Restart=on-failure
RestartSec=10

LimitNOFILE=131072
LimitNPROC=8192

[Install]
WantedBy=multi-user.target
EOF

echo "✅ systemd service created"

# ==========================================================
# STEP 16
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 16: Enabling SonarQube"
echo "=================================================="

systemctl daemon-reload
systemctl enable sonarqube

echo "✅ SonarQube enabled"

# ==========================================================
# STEP 17
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 17: Starting SonarQube"
echo "=================================================="

systemctl restart sonarqube

echo "Waiting for service..."

sleep 10

# ==========================================================
# STEP 18
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 18: Checking service"
echo "=================================================="

if ! systemctl is-active --quiet sonarqube; then

    echo ""
    echo "❌ SonarQube service failed."
    echo ""

    echo "========== SYSTEMD =========="
    systemctl status sonarqube --no-pager || true

    echo ""
    echo "========== JOURNAL =========="
    journalctl -u sonarqube -n 100 --no-pager || true

    echo ""
    echo "========== SONAR LOG =========="
    tail -100 \
        "${SONAR_DIR}/logs/sonar.log" \
        2>/dev/null || true

    exit 1

fi

echo "✅ SonarQube service is running"

# ==========================================================
# STEP 19
# ==========================================================

echo ""
echo "=================================================="
echo "STEP 19: Waiting for SonarQube"
echo "=================================================="

SONAR_READY=false

for i in $(seq 1 60); do

    STATUS=$(curl \
        --silent \
        --connect-timeout 2 \
        http://127.0.0.1:9000/api/system/status \
        || true)

    echo "Attempt ${i}/60: ${STATUS}"

    if echo "${STATUS}" | grep -q '"status":"UP"'; then

        SONAR_READY=true
        break

    fi

    sleep 5

done

# ==========================================================
# STEP 20
# ==========================================================

echo ""
echo "=================================================="
echo "FINAL RESULT"
echo "=================================================="

if [ "${SONAR_READY}" = true ]; then

    echo ""
    echo "=========================================="
    echo "✅ SONARQUBE INSTALLATION SUCCESSFUL"
    echo "=========================================="
    echo ""
    echo "SonarQube:"
    echo "http://YOUR_EC2_PUBLIC_IP:9000"
    echo ""
    echo "Default login:"
    echo "Username: admin"
    echo "Password: admin"
    echo ""
    echo "Check service:"
    echo "systemctl status sonarqube"
    echo ""
    echo "Check logs:"
    echo "journalctl -u sonarqube -f"
    echo ""

else

    echo ""
    echo "❌ SonarQube did not become ready."
    echo ""
    echo "Run:"
    echo ""
    echo "systemctl status sonarqube"
    echo ""
    echo "journalctl -u sonarqube -n 100 --no-pager"
    echo ""
    echo "tail -100 ${SONAR_DIR}/logs/sonar.log"
    echo ""

    exit 1

fi