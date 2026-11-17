# AWS EC2 Docker and Portainer Installation Guide

## 1\. Project Overview

This document explains how to install Docker Engine and Portainer CE on an AWS EC2 Ubuntu server, deploy multiple independent Docker containers, verify the installation, and completely clean up Docker resources.

### Project objectives

- Launch an Ubuntu EC2 instance on AWS.
- Install Docker Engine.
- Install Docker Compose.
- Install Portainer CE GUI.
- Deploy an independent Nginx container.
- Deploy an independent Apache2 container.
- Deploy an independent Ubuntu container.
- Manage containers through Portainer.
- Remove all Docker containers, images, volumes, and unused networks.

---

## 2\. AWS Infrastructure Requirements

### EC2 instance configuration

| Parameter | Configuration |
| --- | --- |
| Cloud provider | Amazon Web Services |
| Service | EC2 |
| Number of instances | 1 |
| Instance name | Docker |
| Operating system | Ubuntu 26.04.1 LTS |
| Architecture | 64-bit x86 |
| Instance type | t3.small recommended |
| vCPU | 2 |
| RAM | 2 GB |
| Root EBS volume | 30 GB |
| Storage type | gp3 SSD |
| Public IPv4 | Enabled |
| SSH authentication | PEM key pair |

### Security Group configuration

Create a Security Group named:

`docker-portainer-sg`

Configure these inbound rules:

| Type | Protocol | Port | Source |
| --- | --- | --- | --- |
| SSH | TCP | 22 | My IP |
| Portainer HTTPS | TCP | 9443 | My IP |
| Nginx | TCP | 8080 | My IP |
| Apache2 | TCP | 8081 | My IP |

Restrict administrative access to trusted IP addresses.

Do not expose Docker daemon port 2375 publicly.

---

## 3\. Connect to AWS EC2

Connect using SSH from your local machine.

bash

```bash
ssh -i "docker-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

Check Ubuntu version:

bash

```bash
lsb_release -a
```

Observed environment:

text

```text
Distributor ID: Ubuntu
Description: Ubuntu 26.04.1 LTS
Release: 26.04
Codename: resolute
```

The session used the root account:

text

```text
root@Docker:~#
```

Therefore, the subsequent Linux commands were executed without sudo.

---

## 4\. Update Ubuntu Linux

Update package lists:

bash

```bash
apt update
```

Upgrade installed packages:

bash

```bash
apt upgrade -y
```

Install required packages:

bash

```bash
apt install -y ca-certificates curl
```

Create the Docker keyring directory:

bash

```bash
install -m 0755 -d /etc/apt/keyrings
```

---

## 5\. Install Docker Engine

### Step 1: Download Docker GPG key

bash

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
-o /etc/apt/keyrings/docker.asc
```

Set permissions:

bash

```bash
chmod a+r /etc/apt/keyrings/docker.asc
```

### Step 2: Add the official Docker repository

bash

```bash
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

For the installed Ubuntu version, the repository codename was:

text

```text
resolute
```

Update the package list:

bash

```bash
apt update
```

### Step 3: Install Docker packages

bash

```bash
apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin
```

### Step 4: Enable and start Docker

bash

```bash
systemctl enable docker
systemctl start docker
```

Verify Docker:

bash

```bash
systemctl status docker
```

### Step 5: Verify Docker installation

bash

```bash
docker --version
```

Observed output:

text

```text
Docker version 29.10.0, build fdd4b8e
```

Check Docker Compose:

bash

```bash
docker compose version
```

Observed output:

text

```text
Docker Compose version v5.7.2
```

Test Docker:

bash

```bash
docker run hello-world
```

Expected result:

text

```text
Hello from Docker!

This message shows that your installation
appears to be working correctly.
```

Docker installation was successful.

---

## 6\. Install Portainer CE

Portainer provides a web-based graphical interface for Docker management.

### Step 1: Create a persistent volume

bash

```bash
docker volume create portainer_data
```

Verify:

bash

```bash
docker volume ls
```

Expected:

text

```text
DRIVER    VOLUME NAME
local     portainer_data
```

### Step 2: Install Portainer

bash

```bash
docker run -d \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```

### Step 3: Verify Portainer

bash

```bash
docker ps
```

Check logs:

bash

```bash
docker logs portainer
```

Portainer starts its HTTPS service on port 9443.

### Step 4: Retrieve setup token

bash

```bash
docker logs portainer 2>&1 | grep setup_token
```

Copy the token from the output if the initial setup screen requests it.

Do not share the setup token publicly.

### Step 5: Access Portainer

Open:

text

```text
https://YOUR_EC2_PUBLIC_IP:9443
```

Complete the initial setup:

1. Enter administrator username.
2. Create a strong password.
3. Enter the setup token if requested.
4. Click Create user.
5. Select Get Started.
6. Select the local Docker environment.

Portainer installation is complete.

---

## 7\. Deploy Nginx Container

Nginx is deployed as an independent Docker container.

### Container configuration

| Parameter | Value |
| --- | --- |
| Container name | nginx-web |
| Image | nginx:latest |
| Host port | 8080 |
| Container port | 80 |
| Protocol | TCP |
| Restart policy | Unless stopped |

### Deploy using Docker CLI

bash

```bash
docker run -d \
  --name nginx-web \
  --restart unless-stopped \
  -p 8080:80 \
  nginx:latest
```

### Verify

bash

```bash
docker ps
```

Access:

text

```text
http://YOUR_EC2_PUBLIC_IP:8080
```

Expected result:

Nginx welcome page.

---

## 8\. Deploy Apache2 Container

Apache2 is deployed as a separate container using Ubuntu 24.04 as its base image.

### Container configuration

| Parameter | Value |
| --- | --- |
| Container name | apache2-web |
| Base image | ubuntu:24.04 |
| Web server | Apache2 |
| Host port | 8081 |
| Container port | 80 |
| Protocol | TCP |

### Docker Compose configuration

Create:

`apache-compose.yml`

yaml

```yaml
services:
  apache2:
    image: ubuntu:24.04
    container_name: apache2-web
    restart: unless-stopped
    ports:
      - "8081:80"
    command: >
      bash -c "apt-get update &&
      DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 &&
      echo '<h1>Apache2 Server Running Successfully</h1>' > /var/www/html/index.html &&
      apachectl -D FOREGROUND"
```

Deploy:

bash

```bash
docker compose -f apache-compose.yml up -d
```

Verify:

bash

```bash
docker ps
```

Check logs:

bash

```bash
docker logs apache2-web
```

Access:

text

```text
http://YOUR_EC2_PUBLIC_IP:8081
```

Expected result:

text

```text
Apache2 Server Running Successfully
```

Note: This basic example installs Apache2 at container startup. For persistent web content and faster restarts, use a custom Dockerfile and persistent volume.

---

## 9\. Deploy Separate Ubuntu Container

An independent Ubuntu container was created for Linux command-line practice.

### Container configuration

| Parameter | Value |
| --- | --- |
| Container name | ubuntu-server |
| Image | ubuntu:24.04 |
| Host port | None |
| Container port | None |
| Restart policy | Unless stopped |
| Command | sleep infinity |

### Docker Compose configuration

yaml

```yaml
services:
  ubuntu:
    image: ubuntu:24.04
    container_name: ubuntu-server
    restart: unless-stopped
    command: sleep infinity
    tty: true
    stdin_open: true
```

Deploy:

bash

```bash
docker compose -f ubuntu-compose.yml up -d
```

### Access Ubuntu terminal

bash

```bash
docker exec -it ubuntu-server bash
```

Inside the container:

bash

```bash
apt update
```

Install Linux utilities:

bash

```bash
apt install -y curl wget vim nano iputils-ping net-tools
```

Check Ubuntu version:

bash

```bash
cat /etc/os-release
```

Exit:

bash

```bash
exit
```

The Ubuntu container has its own filesystem and userspace but shares the host Linux kernel.

---

## 10\. Combined Docker Compose Configuration

The following Compose file describes all three application containers together.

File name:

`docker-compose.yml`

yaml

```yaml
services:

  nginx:
    image: nginx:latest
    container_name: nginx-web
    restart: unless-stopped
    ports:
      - "8080:80"

  apache2:
    image: ubuntu:24.04
    container_name: apache2-web
    restart: unless-stopped
    ports:
      - "8081:80"
    command: >
      bash -c "apt-get update &&
      DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 &&
      echo '<h1>Apache2 Server Running Successfully</h1>' > /var/www/html/index.html &&
      apachectl -D FOREGROUND"

  ubuntu:
    image: ubuntu:24.04
    container_name: ubuntu-server
    restart: unless-stopped
    command: sleep infinity
    tty: true
    stdin_open: true
```

Deploy:

bash

```bash
docker compose up -d
```

Important: In this project, Nginx was already running independently before the combined stack was considered. Do not deploy another Nginx service on port 8080 while the existing container owns that port. Use either the existing container or a Compose-managed replacement, not both.

---

## 11\. Manage Containers Using Portainer

Portainer GUI URL:

text

```text
https://YOUR_EC2_PUBLIC_IP:9443
```

Useful Portainer sections:

| Section | Purpose |
| --- | --- |
| Containers | Start, stop, restart and remove containers |
| Images | Download and remove Docker images |
| Networks | Manage Docker networking |
| Volumes | Manage persistent storage |
| Stacks | Deploy Docker Compose applications |
| Console | Open container terminals |
| Events | View Docker events |

To access the Ubuntu container:

1. Open Portainer.
2. Select local environment.
3. Go to Containers.
4. Select ubuntu-server.
5. Click Console.
6. Select `/bin/bash`.
7. Click Connect.

---

## 12\. Verify All Containers

Execute:

bash

```bash
docker ps -a
```

Expected running containers before cleanup:

| Container | Image | Port | Status |
| --- | --- | --- | --- |
| nginx-web | nginx:latest | 8080:80 | Up |
| apache2-web | ubuntu:24.04 | 8081:80 | Up |
| ubuntu-server | ubuntu:24.04 | None | Up |
| portainer | portainer/portainer-ce:lts | 9443:9443 | Up |

### Verify images

bash

```bash
docker images
```

### Verify volumes

bash

```bash
docker volume ls
```

### Verify networks

bash

```bash
docker network ls
```

### Verify running containers

bash

```bash
docker ps
```

---

## 13\. Important Docker Commands

### Container management

List running containers:

bash

```bash
docker ps
```

List all containers:

bash

```bash
docker ps -a
```

Stop container:

bash

```bash
docker stop nginx-web
```

Start container:

bash

```bash
docker start nginx-web
```

Restart container:

bash

```bash
docker restart nginx-web
```

Remove container:

bash

```bash
docker rm -f nginx-web
```

### Image management

List images:

bash

```bash
docker images
```

Pull image:

bash

```bash
docker pull nginx:latest
```

Remove image:

bash

```bash
docker rmi nginx:latest
```

### Volume management

List volumes:

bash

```bash
docker volume ls
```

Inspect volume:

bash

```bash
docker volume inspect portainer_data
```

Remove volume:

bash

```bash
docker volume rm portainer_data
```

### Logs and inspection

View logs:

bash

```bash
docker logs nginx-web
```

Inspect container:

bash

```bash
docker inspect nginx-web
```

View resource usage:

bash

```bash
docker stats
```

---

## 14\. Complete Docker Cleanup

After testing, all Docker resources were removed to return the environment to a clean Docker state.

**WARNING:** These commands permanently remove Docker containers, images, volumes, and application data. They also remove Portainer and its persistent database. Back up any required data before proceeding.

### Step 1: Stop all containers

bash

```bash
docker stop $(docker ps -aq) 2>/dev/null
```

### Step 2: Remove all containers

bash

```bash
docker rm -f $(docker ps -aq) 2>/dev/null
```

### Step 3: Remove all Docker images

bash

```bash
docker rmi -f $(docker images -aq) 2>/dev/null
```

### Step 4: Remove all Docker volumes

bash

```bash
docker volume rm -f $(docker volume ls -q) 2>/dev/null
```

This also removes the Portainer data volume.

### Step 5: Remove unused Docker networks

bash

```bash
docker network prune -f
```

### Step 6: Complete Docker cleanup

bash

```bash
docker system prune -a --volumes -f
```

### Step 7: Verify cleanup

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

Check networks:

bash

```bash
docker network ls
```

Expected final state:

- No Docker containers.
- No Docker images.
- No Docker volumes.
- Only the default Docker networks remain (`bridge`, `host`, `none`).

Docker Engine remains installed and running.

Ubuntu EC2 and its EBS volume remain intact.

Portainer has been removed and must be reinstalled if required.

---

## 15\. Final Project Summary

### AWS resources

| Resource | Quantity |
| --- | --- |
| AWS EC2 instance | 1 |
| Ubuntu Linux host | 1 |
| EBS storage volume | 1 |
| Security Group | 1 |
| Public IPv4 | 1 |

### Docker components installed

| Component | Quantity |
| --- | --- |
| Docker Engine | 1 |
| Docker Compose plugin | 1 |
| Portainer CE | 1 |
| Nginx container | 1 |
| Apache2 container | 1 |
| Ubuntu container | 1 |

### Access URLs used

| Service | URL |
| --- | --- |
| Portainer | https://YOUR\_EC2\_PUBLIC\_IP:9443 |
| Nginx | http://YOUR\_EC2\_PUBLIC\_IP:8080 |
| Apache2 | http://YOUR\_EC2\_PUBLIC\_IP:8081 |
| Ubuntu | Portainer Console or Docker exec |

### Final result

Successfully completed the following practical exercises:

1. Created an AWS EC2 Ubuntu instance.
2. Installed Docker Engine 29.10.0.
3. Installed Docker Compose 5.7.2.
4. Installed Portainer CE 2.45.3.
5. Configured Docker management through Portainer.
6. Deployed Nginx as an independent container.
7. Deployed Apache2 as an independent container.
8. Deployed Ubuntu as an independent container.
9. Verified all containers were running.
10. Removed all Docker containers, images, volumes, and unused networks.

**Final infrastructure state:** Docker Engine remains installed on the AWS EC2 Ubuntu server, while the Docker application resources have been cleared.

---

## 16\. Official Documentation

- AWS EC2: [https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2\_GetStarted.html](<https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html>)
- Docker Engine Ubuntu installation: [https://docs.docker.com/engine/install/ubuntu/](<https://docs.docker.com/engine/install/ubuntu/>)
- Docker Compose: [https://docs.docker.com/compose/](<https://docs.docker.com/compose/>)
- Docker CLI: [https://docs.docker.com/reference/cli/docker/](<https://docs.docker.com/reference/cli/docker/>)
- Portainer: [https://docs.portainer.io/](<https://docs.portainer.io/>)
- Nginx: [https://nginx.org/en/docs/](<https://nginx.org/en/docs/>)
- Apache HTTP Server: [https://httpd.apache.org/docs/](<https://httpd.apache.org/docs/>)
- Ubuntu: [https://ubuntu.com/server/docs](<https://ubuntu.com/server/docs>)

## Document completion

This document covers the complete practical workflow, from creating your EC2 instance through installing and testing Docker services to clearing all Docker resources.

One important note: Your final cleanup removed Portainer and its data volume, but did not uninstall Docker Engine or remove the AWS EC2 instance.