
# Download and Run Docker Script

## Download the File

### On Ubuntu, RHEL, or Amazon Linux

You can download the script using **curl**:

```bash
curl -O https://raw.githubusercontent.com/sujalkamanna/scripts/main/docker.sh
````

Or using **wget**:

```bash
wget https://raw.githubusercontent.com/sujalkamanna/scripts/main/docker.sh
```

> Note: `curl` and `wget` are Linux commands and will work in Ubuntu, RHEL, Amazon Linux, or other Linux distributions.

---

### On Windows

You can download the script using **winget**:

```powershell
winget install https://raw.githubusercontent.com/sujalkamanna/scripts/main/docker.sh
```

> Note: The script is a Linux shell script, so on Windows you must run it in **WSL, Git Bash, or another Bash-compatible environment**.

---

## Run the Script

After downloading, run the script using:

```bash
chmod +x docker.sh   # Make it executable (Linux only)
./docker.sh
```

Or alternatively:

```bash
sh docker.sh
```
---
