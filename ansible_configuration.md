---

# **Step-by-Step Ansible Setup on AWS EC2 Ubuntu**

---

## **STEP 1 — Prepare MASTER (Ansible Controller)**

1. **Update packages**

```bash
sudo apt update -y
sudo apt upgrade -y
```

2. **Install Python3**

```bash
sudo apt install python3 -y
```

3. **Install Ansible**

```bash
sudo apt install ansible -y
ansible --version
```

4. **Generate SSH key**

```bash
ssh-keygen -t rsa -b 4096
# Press Enter for all prompts (no passphrase)
```

5. **Display the public key** (to copy to Slave)

```bash
cat ~/.ssh/id_rsa.pub
```

> Copy this output — will paste on the Slave in the next step.

---

## **STEP 2 — Prepare SLAVE (Managed Node)**

1. **Update packages**

```bash
sudo apt update -y
sudo apt upgrade -y
```

2. **Install Python3**

```bash
sudo apt install python3 -y
```

3. **Ensure SSH is enabled**

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

4. **Add Master’s public key for passwordless SSH**

```bash
mkdir -p /root/.ssh
nano /root/.ssh/authorized_keys
# Paste the master’s public key here
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

5. **Test SSH login from Master** (on Master)

```bash
ssh root@<slave_IP>
# Should login without password
```

---

## **STEP 3 — Configure Ansible on MASTER**

1. **Create Ansible directory and hosts file**

```bash
sudo mkdir -p /etc/ansible
sudo vi /etc/ansible/hosts
```

Add:

```ini
[slave_nodes]
slave1 ansible_host=<slave_IP> ansible_user=root
```

2. **Test Ansible connectivity**

```bash
ansible all -m ping
```

Expected output:

```
slave1 | SUCCESS => { "ping": "pong" }
```

---

# ✅ **Summary Table (Master vs Slave)**

| Step                     | Master   | Slave                        |
| ------------------------ | -------- | ---------------------------- |
| Update system            | ✔        | ✔                            |
| Install Python3          | ✔        | ✔                            |
| Install Ansible          | ✔        | ❌                            |
| Generate SSH key         | ✔        | ❌                            |
| Copy Master key to Slave | ✔ (copy) | ✔ (paste in authorized_keys) |
| Enable SSH               | ❌        | ✔                            |
| Test passwordless SSH    | ✔        | ❌                            |
| Create hosts file        | ✔        | ❌                            |
| Test `ansible ping`      | ✔        | ❌                            |

---
