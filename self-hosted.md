## **Step-by-step Script**


```bash
#!/bin/bash

# -----------------------------
# GitHub Actions Self-Hosted Runner Setup Script
# -----------------------------

# Exit immediately if a command exits with a non-zero status
set -e

# 1️⃣ Install prerequisites if missing
echo "Checking for prerequisites..."

# Check curl
if ! command -v curl &> /dev/null; then
  echo "curl not found, installing..."
  sudo apt update
  sudo apt install -y curl
else
  echo "curl is already installed."
fi

# Check tar
if ! command -v tar &> /dev/null; then
  echo "tar not found, installing..."
  sudo apt update
  sudo apt install -y tar
else
  echo "tar is already installed."
fi

# Optional: install tzdata if you plan to use timezone commands
if ! dpkg -s tzdata &> /dev/null; then
  echo "tzdata not found, installing..."
  sudo apt install -y tzdata
fi

# 2️⃣ Create runner directory
RUNNER_DIR=~/actions-runner
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# 3️⃣ Download the latest runner
echo "Downloading GitHub Actions runner..."
curl -o actions-runner-linux-x64.tar.gz -L \
https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64.tar.gz

# 4️⃣ Extract the runner
echo "Extracting runner..."
tar xzf ./actions-runner-linux-x64.tar.gz

# 5️⃣ Configure the runner
echo "⚠️ Please enter your GitHub repository URL and token."
echo "Example URL: https://github.com/YOUR_USERNAME/YOUR_REPO"
read -p "GitHub Repository URL: " REPO_URL
read -s -p "GitHub Runner Token: " RUNNER_TOKEN
echo

# Run configuration (do NOT use sudo)
./config.sh --url "$REPO_URL" --token "$RUNNER_TOKEN"

# 6️⃣ Run the runner
echo "Starting runner in interactive mode..."
echo "Use Ctrl+C to stop. To run as a service, run './svc.sh install' and './svc.sh start'"
./run.sh
```

---

### ✅ Features of this script

1. Checks if **`curl`**, **`tar`**, and optionally **`tzdata`** are installed; installs them if missing.
2. Creates a **runner directory** in the user’s home folder.
3. Downloads and extracts the **latest GitHub Actions runner**.
4. Prompts for **repository URL** and **token** (keeps token hidden).
5. Configures the runner safely (no `sudo`).
6. Starts the runner in **interactive mode**, with instructions for running as a service.

---

### Next Steps After Running

* **For persistent background execution**:

```bash
cd ~/actions-runner
sudo ./svc.sh install
sudo ./svc.sh start
```

* **In workflow YAML**, use:

```yaml
runs-on: self-hosted
```

* Optional: add labels to target specific runners.

---
