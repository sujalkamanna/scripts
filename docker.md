
# Docker Installation

### On Ubuntu, RHEL, or Amazon Linux

You can install Docker using the following methods.

**Method 1: Install using APT (Ubuntu/Debian)**

bash

```bash
sudo apt update
sudo apt-get install -y docker.io
```

> Note: `docker.io` is the distribution-maintained Docker package. It may not be the latest official Docker Engine release.

**Method 2: Download the custom Docker installation script**

Using **curl**:

bash

```bash
curl -O https://raw.githubusercontent.com/sujalkamanna/scripts/main/docker.sh
```

Or using **wget**:

bash

```bash
wget https://raw.githubusercontent.com/sujalkamanna/scripts/main/docker.sh
```

**Method 3: Install using the official Docker convenience script**

bash

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
```

Preview installation:

bash

```bash
sudo sh ./get-docker.sh --dry-run
```

Install Docker:

bash

```bash
sudo sh ./get-docker.sh
```

> Note: The convenience script detects your Linux distribution and configures the package manager to install Docker Engine, containerd, and runc. It is recommended for development and testing, not production environments.

---

### On Windows

Docker installation scripts are Linux shell scripts and cannot be executed directly in Windows PowerShell.

You can use:

- **WSL2:** Run the installation script inside an Ubuntu or other supported Linux distribution.
- **Git Bash:** Use only if the environment supports the required Linux commands and package manager. WSL2 is recommended.

---

## Run the Script

After downloading your custom installation script, execute:

bash

```bash
chmod +x docker.sh
./docker.sh
```

Or alternatively:

bash

```bash
sh docker.sh
```

---

## Verify Docker Installation

Check Docker version:

bash

```bash
docker --version
```

Check Docker service:

bash

```bash
sudo systemctl status docker --no-pager
```

Test Docker:

bash

```bash
sudo docker run hello-world
```

---

> **Important Notes:**- The Docker convenience script installs the latest stable Docker Engine by default.
> - Installation requires root or sudo privileges.
> - Always review downloaded scripts before executing them.
> - The convenience script is not recommended for production environments.
> - For production, prefer the official Docker package repository installation method.

Official documentation: https://docs.docker.com/engine/install/