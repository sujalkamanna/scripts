# Docker & Portainer CE Installation Guide on Ubuntu Linux

**Document Type:** Installation, Configuration, Troubleshooting and Removal Guide\
**Platform:** Ubuntu Linux\
**Container Runtime:** Docker Engine\
**Management Interface:** Portainer Community Edition (CE)\
**Deployment:** Standalone Docker using Docker Compose\
**Web Interface:** HTTPS (Port 9443)\
**Docker Swarm:** Not required

---

# 1\. Overview

This document describes how to install Docker Engine and Portainer Community Edition (CE) on Ubuntu Linux.

Portainer provides a web-based graphical interface to manage:

- Docker containers
- Docker images
- Docker volumes
- Docker networks
- Docker Compose applications
- Container logs and terminal
- Application stacks

## Architecture

| Component | Configuration |
| --- | --- |
| Operating System | Ubuntu Linux |
| Container Runtime | Docker Engine |
| Management GUI | Portainer CE |
| Deployment Method | Docker Compose |
| Web Interface | HTTPS |
| Portainer URL | `https://SERVER_IP:9443` |
| Docker Swarm | Not required |
| Portainer Agent | Not required for local Docker |

**Important:** This guide uses standalone Docker. Do not use `docker stack deploy` or the Portainer Agent Stack YAML for this installation.

---

# 2\. Install Docker Engine

## 2.1 Update Ubuntu packages

bash

```bash
sudo apt update
sudo apt install -y ca-certificates curl
```

## 2.2 Create Docker keyring directory

bash

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

## 2.3 Download Docker GPG key

bash

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc
```

## 2.4 Add Docker repository

bash

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

## 2.5 Install Docker

bash

```bash
sudo apt update

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

## 2.6 Enable and start Docker

bash

```bash
sudo systemctl enable --now docker
```

## 2.7 Verify Docker installation

bash

```bash
sudo docker run hello-world
```

Check Docker version:

bash

```bash
sudo docker version
```

Check Docker service:

bash

```bash
sudo systemctl status docker
```

---

# 3\. Create Portainer Installation Directory

Create the installation directory:

bash

```bash
mkdir -p ~/portainer
cd ~/portainer
```

Directory structure:

text

```text
portainer/
└── docker-compose.yml
```

---

# 4\. Create Portainer Docker Compose YAML

## 4.1 Create configuration file

bash

```bash
nano docker-compose.yml
```

## 4.2 Add the following configuration

yaml

```yaml
services:
  portainer:
    image: portainer/portainer-ce:lts
    container_name: portainer
    restart: always

    ports:
      - "9443:9443"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
    name: portainer_data
```

Save the file.

## 4.3 Configuration explanation

| Configuration | Purpose |
| --- | --- |
| `portainer/portainer-ce:lts` | Portainer CE image |
| `9443:9443` | HTTPS web interface |
| `docker.sock` | Access to local Docker Engine |
| `portainer_data` | Persistent Portainer data |
| `restart: always` | Automatically restart container |

### Port explanation

| Port | Purpose | Required |
| --- | --- | --- |
| 9443 | HTTPS web interface | Yes |
| 8000 | Edge Agent tunnel | No |
| 9000 | Legacy HTTP interface | No |

For this local standalone installation, only port 9443 is published.

**Security note:** Mounting `/var/run/docker.sock` gives Portainer extensive control over Docker and effectively root-level control of the host. Only trusted administrators should have access.

---

# 5\. Deploy Portainer

## 5.1 Validate Docker Compose configuration

bash

```bash
sudo docker compose config -q
```

## 5.2 Start Portainer

bash

```bash
sudo docker compose up -d
```

## 5.3 Check running containers

bash

```bash
sudo docker ps
```

## 5.4 Check Portainer logs

bash

```bash
sudo docker logs portainer
```

## 5.5 Check Compose status

bash

```bash
sudo docker compose ps
```

## 5.6 Verify persistent volume

bash

```bash
sudo docker volume ls
```

Expected volume:

text

```text
portainer_data
```

---

# 6\. Access Portainer GUI

Open a web browser.

### Remote access

text

```text
https://SERVER_IP:9443
```

### Local access

text

```text
https://localhost:9443
```

### Example

text

```text
https://192.168.1.100:9443
```

Replace the IP address with your Ubuntu server IP.

Find the server IP:

bash

```bash
hostname -I
```

Portainer uses a self-signed SSL certificate by default. Your browser may display a certificate warning.

Verify that you are connecting to your own server before proceeding.

---

# 7\. Initial Portainer Setup

Complete the initial configuration:

1. Open Portainer in your browser.
2. Create an administrator username.
3. Set a strong password.
4. Click **Create User**.
5. Select **Get Started** if displayed.
6. Select the automatically detected local Docker environment if required.

The first administrator account must be created within five minutes of starting a fresh Portainer installation.

After setup, the Portainer dashboard will be available.

---

# 8\. Fix: Portainer Instance Timed Out

## Error

text

```text
Your Portainer instance has timed out for security purposes.

To re-enable your Portainer instance,
you will need to restart Portainer.
```

## Cause

Portainer automatically disables the initial setup service if the administrator account is not created within five minutes.

This is a security measure to prevent unauthorized initial configuration.

## Solution

Stop and start the Portainer container:

bash

```bash
sudo docker stop portainer
sudo docker start portainer
```

Alternatively:

bash

```bash
sudo docker restart portainer
```

Immediately reopen:

text

```text
https://SERVER_IP:9443
```

Complete the administrator setup within five minutes.

**Important:** Do not delete the persistent Portainer data volume.

If the problem occurs on a previously working installation, verify that the correct persistent volume is mounted to `/data`.

---

# 9\. Fix: Portainer Setup Token

During initial setup, Portainer may request a Setup Token.

## 9.1 Retrieve token from server logs

bash

```bash
sudo docker logs portainer 2>&1 | grep -i token
```

If required, inspect the complete logs:

bash

```bash
sudo docker logs portainer
```

## 9.2 Restart Portainer if setup has timed out

bash

```bash
sudo docker restart portainer
```

Check recent logs:

bash

```bash
sudo docker logs --since 2m portainer
```

## 9.3 Enter the token

1. Open `https://SERVER_IP:9443`.
2. Copy the setup token from the server logs.
3. Paste it into the Setup Token field.
4. Continue with administrator account creation.

**Security:** Never share your setup token publicly. Treat it as a secret.

---

# 10\. Fix: HTTP Request to HTTPS Server

## Error

text

```text
Client sent an HTTP request to an HTTPS server.
```

## Cause

Portainer's web interface on port 9443 expects HTTPS, not HTTP.

### Incorrect URL

text

```text
http://SERVER_IP:9443
```

### Correct URL

text

```text
https://SERVER_IP:9443
```

Always use HTTPS when accessing port 9443.

---

# 11\. Portainer Management Commands

Run these commands from the Portainer installation directory unless otherwise specified.

## Start Portainer

bash

```bash
cd ~/portainer
sudo docker compose start
```

## Stop Portainer

bash

```bash
cd ~/portainer
sudo docker compose stop
```

## Restart Portainer

bash

```bash
cd ~/portainer
sudo docker compose restart
```

## Check Portainer logs

bash

```bash
cd ~/portainer
sudo docker compose logs -f
```

## Check container status

bash

```bash
sudo docker compose ps
```

## Update Portainer

bash

```bash
cd ~/portainer

sudo docker compose pull
sudo docker compose up -d
```

## Stop and remove the container

bash

```bash
cd ~/portainer
sudo docker compose down
```

This removes the Compose-managed container and network but does not remove the named `portainer_data` volume.

## Check Portainer data volume

bash

```bash
sudo docker volume inspect portainer_data
```

## Check Docker resources

bash

```bash
sudo docker ps -a
sudo docker images
sudo docker volume ls
sudo docker network ls
```

---

# 12\. Complete Portainer Installation Script

Save the following script as:

`install-portainer.sh`

This script assumes Docker Engine and Docker Compose are already installed.

It checks for an existing Portainer installation before creating a new one.

bash

```bash
#!/bin/bash

set -e

echo "======================================"
echo " Docker & Portainer Installation"
echo "======================================"

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed."
    echo "Please install Docker Engine first."
    exit 1
fi

# Check Docker Compose
if ! docker compose version >/dev/null 2>&1; then
    echo "ERROR: Docker Compose plugin is not installed."
    exit 1
fi

# Check Docker service
sudo systemctl enable --now docker

# Prevent accidental replacement of an existing container
if sudo docker container inspect portainer >/dev/null 2>&1; then
    echo "ERROR: Portainer container already exists."
    echo "Please inspect the existing installation."
    exit 1
fi

# Prevent conflict with an existing Swarm service
if sudo docker service ls \
    --format '{{.Name}}' | grep -q '^portainer_portainer$'; then
    echo "ERROR: Portainer Swarm service already exists."
    echo "Remove or migrate the existing Swarm installation first."
    exit 1
fi

# Create installation directory
mkdir -p "$HOME/portainer"

cd "$HOME/portainer"

# Create Docker Compose configuration
cat > docker-compose.yml <<'EOF'
services:
  portainer:
    image: portainer/portainer-ce:lts
    container_name: portainer
    restart: always

    ports:
      - "9443:9443"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
    name: portainer_data
EOF

# Validate Docker Compose configuration
sudo docker compose config -q

# Start Portainer
sudo docker compose up -d

echo ""
echo "======================================"
echo " Portainer Installation Completed"
echo "======================================"

# Display container status
sudo docker ps --filter name=portainer

# Display access information
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo ""
echo "Portainer GUI:"
echo "https://${IP_ADDRESS}:9443"

echo ""
echo "Useful commands:"
echo "Start:   cd ~/portainer && sudo docker compose start"
echo "Stop:    cd ~/portainer && sudo docker compose stop"
echo "Restart: cd ~/portainer && sudo docker compose restart"
echo "Logs:    cd ~/portainer && sudo docker compose logs -f"
echo "Status:  sudo docker ps"
```

## 12.1 Execute the installation script

Give execute permission:

bash

```bash
chmod +x install-portainer.sh
```

Run:

bash

```bash
./install-portainer.sh
```

**Note:** The script does not overwrite an existing Portainer installation or delete its persistent data. If an existing Swarm deployment is detected, remove or migrate it before proceeding.

---

# 13\. Network and Port Configuration

## Port details

| Port | Protocol | Purpose |
| --- | --- | --- |
| 9443 | TCP / HTTPS | Portainer web GUI |
| 8000 | TCP | Optional Edge Agent tunnel |
| 9000 | TCP / HTTP | Legacy Portainer web interface |

For this installation, only port 9443 is published.

## 13.1 Configure Ubuntu Firewall

Check UFW status:

bash

```bash
sudo ufw status
```

If UFW is enabled and remote access is required, allow access only from your trusted management network:

bash

```bash
sudo ufw allow from 192.168.1.0/24 to any port 9443 proto tcp
```

Replace the example subnet with your actual trusted network.

Verify:

bash

```bash
sudo ufw status
```

**Security recommendations:**

- Do not expose the Docker socket to external networks.
- Do not expose Portainer directly to the public internet.
- Use strong administrator passwords.
- Restrict access to trusted management networks.
- Use a trusted SSL certificate for production environments.

---

# 14\. Final Verification Checklist

## Docker Verification

- [ ]Docker Engine installed.
- [ ]Docker service running.
- [ ]Docker Compose plugin installed.
- [ ]Docker hello-world test successful.

## Portainer Verification

- [ ]Portainer container running.
- [ ]Portainer data volume created.
- [ ]HTTPS port 9443 accessible.
- [ ]Administrator account created.
- [ ]Local Docker environment connected.
- [ ]Portainer dashboard accessible.
- [ ]Container restart policy configured.

## Deployment Verification

- [ ]Standalone Docker deployment used.
- [ ]Docker Swarm not required.
- [ ]Portainer Agent not required for local Docker.
- [ ]Persistent storage configured.

---

# 15\. Official Documentation

## Docker Documentation

- Docker Engine installation: [https://docs.docker.com/engine/install/ubuntu/](<https://docs.docker.com/engine/install/ubuntu/>)
- Docker Compose: [https://docs.docker.com/compose/](<https://docs.docker.com/compose/>)
- Docker post-installation: https://docs.docker.com/engine/install/linux-postinstall/

## Portainer Documentation

- Portainer CE documentation: [https://docs.portainer.io/](<https://docs.portainer.io/>)
- Portainer installation: [https://docs.portainer.io/start/install-ce/server/docker/linux](<https://docs.portainer.io/start/install-ce/server/docker/linux>)
- Portainer initial setup: [https://docs.portainer.io/start/install-ce/server/setup](<https://docs.portainer.io/start/install-ce/server/setup>)
- Portainer troubleshooting: [https://docs.portainer.io/faq/troubleshooting](<https://docs.portainer.io/faq/troubleshooting>)
- Portainer setup timeout: [https://docs.portainer.io/faqs/installing/your-portainer-instance-has-timed-out-for-security-purposes-error-fix](<https://docs.portainer.io/faqs/installing/your-portainer-instance-has-timed-out-for-security-purposes-error-fix>)

---

# 16\. Completely Remove Portainer from Docker Swarm

This section explains how to remove Portainer CE and Portainer Agent from an existing Docker Swarm environment.

**Important:** This section applies only if Portainer was deployed using Docker Swarm. It is not required for the standalone Docker Compose installation in Sections 1–15.

## 16.1 Identify Portainer Swarm services

Check services:

bash

```bash
docker service ls
```

Check Portainer tasks:

bash

```bash
docker node ps
```

Typical services:

text

```text
portainer_agent
portainer_portainer
```

## 16.2 Remove Portainer Stack

Run this command on a Swarm manager node:

bash

```bash
docker stack rm portainer
```

This removes the Portainer stack and its associated services.

## 16.3 Wait for services to stop

bash

```bash
sleep 10
```

Check remaining services:

bash

```bash
docker service ls
```

If the services are still present, wait until they have been removed before proceeding.

## 16.4 Check remaining Portainer containers

bash

```bash
docker ps -a --format '{{.ID}} {{.Names}}' | grep portainer
```

If any standalone Portainer containers remain, remove them:

bash

```bash
docker ps -aq --filter name=portainer | xargs -r docker rm -f
```

Only perform this after the Swarm services have been removed.

## 16.5 Remove Portainer images (Optional)

List Portainer images:

bash

```bash
docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep portainer
```

Remove Portainer images:

bash

```bash
docker images --format '{{.Repository}}:{{.Tag}}' \
  | grep '^portainer/' \
  | sort -u \
  | xargs -r docker rmi
```

Only remove images that are no longer required by other applications.

## 16.6 Remove Portainer volumes (Optional)

**WARNING: This permanently deletes Portainer configuration, users, settings and stored Portainer data.**

List volumes:

bash

```bash
docker volume ls
```

Find Portainer-related volumes:

bash

```bash
docker volume ls --format '{{.Name}}' | grep portainer
```

A standalone Compose installation may use:

text

```text
portainer_data
```

A Swarm stack may use a stack-prefixed volume name, such as:

text

```text
portainer_portainer_data
```

Inspect the exact volume name before removing it.

Remove the appropriate Portainer data volume:

bash

```bash
docker volume rm portainer_data
```

Replace the volume name if your Swarm installation used a different name.

Only remove the volume if you want a completely fresh installation.

## 16.7 Verify Portainer removal

Check Docker services:

bash

```bash
docker service ls
```

Check containers:

bash

```bash
docker ps -a
```

Check images:

bash

```bash
docker images
```

Check volumes:

bash

```bash
docker volume ls
```

Check stacks:

bash

```bash
docker stack ls
```

There should be no remaining Portainer services or containers.

**Note:** Historical Swarm task records may appear temporarily during service removal. They are not necessarily active containers.

## 16.8 Disable Docker Swarm (Optional)

If you no longer need Docker Swarm, leave the Swarm:

bash

```bash
docker swarm leave --force
```

**Important:**

- Do not execute this command if you still need the node to participate in a Docker Swarm cluster.
- On a multi-node cluster, consider the effect on manager quorum before removing a manager.
- This command does not uninstall Docker Engine.

## 16.9 Important Cleanup Notes

| Component | Action |
| --- | --- |
| Portainer Stack | Remove |
| Portainer Agent | Removed with stack |
| Portainer Server | Removed with stack |
| Portainer Containers | Remove remaining containers |
| Portainer Images | Optional removal |
| Portainer Data Volume | Optional removal |
| Docker Engine | Keep installed |
| Docker Compose | Keep installed |
| Docker Swarm | Optional removal |

## 16.10 Complete Portainer Removal Command Sequence

Run the following commands on the Swarm manager for a complete Portainer cleanup.

bash

```bash
# Remove Portainer stack
docker stack rm portainer

# Wait for service shutdown
sleep 10

# Check remaining Portainer services
docker service ls

# Remove remaining standalone Portainer containers
docker ps -aq --filter name=portainer | xargs -r docker rm -f

# Remove Portainer images
docker images --format '{{.Repository}}:{{.Tag}}' \
  | grep '^portainer/' \
  | sort -u \
  | xargs -r docker rmi

# Inspect Portainer-related volumes
docker volume ls --format '{{.Name}}' | grep portainer

# Remove the appropriate Portainer volume ONLY if data deletion is intended
docker volume rm portainer_data

# Verify cleanup
docker service ls
docker ps -a
docker stack ls
docker volume ls
```

If Swarm is no longer required and it is safe to remove this node:

bash

```bash
docker swarm leave --force
```

**Note:** Review the volume name before executing the volume removal command. Do not delete volumes belonging to other applications.

---

# 17\. Final Installation Summary

## Successful Deployment Configuration

| Item | Final Configuration |
| --- | --- |
| Operating System | Ubuntu Linux |
| Docker Engine | Installed |
| Docker Compose | Installed |
| Portainer CE | Installed |
| Deployment Method | Docker Compose |
| Docker Swarm | Not required |
| Portainer Agent | Not required |
| Web Interface | HTTPS |
| Access Port | 9443 |
| Data Volume | `portainer_data` |
| Container Restart | Always |

## Final Access URL

text

```text
https://SERVER_IP:9443
```

## Persistent Storage

text

```text
portainer_data
```

## Main Installation Commands

bash

```bash
# Start Portainer
cd ~/portainer
sudo docker compose up -d

# Check status
sudo docker compose ps

# View logs
sudo docker compose logs -f

# Restart Portainer
sudo docker compose restart

# Update Portainer
sudo docker compose pull
sudo docker compose up -d
```

---

**Final Status:** Docker Engine and Portainer CE successfully installed and accessible through HTTPS.

**Deployment Type:** Standalone Docker using Docker Compose.

**Docker Swarm:** Not required.

**Persistent Storage:** Docker named volume `portainer_data`.

**Documentation Scope:** Installation, configuration, initial setup, troubleshooting, maintenance, security and complete Swarm cleanup.