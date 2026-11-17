# Ansible Master–Slave Configuration Guide

## 1. Architecture

Ansible uses one machine as the **Master/Controller** and one or more machines as **Managed Nodes/Slaves**.

Example setup:

```text
                    Ansible Controller
                    172.31.0.88
                         |
                         | SSH
                         | SSH Key
                         ↓
              ┌──────────────────────┐
              │   Managed Node       │
              │   slave1             │
              │   172.31.13.50       │
              └──────────────────────┘
```

In this setup:

| Machine  | IP Address     | Role               |
| -------- | -------------- | ------------------ |
| Server 1 | `172.31.0.88`  | Ansible Controller |
| Server 2 | `172.31.13.50` | Managed Node       |

The controller connects to the managed node using SSH.

---

# 2. Prerequisites

The following should be available:

* Two Linux machines
* Network connectivity between the machines
* Ansible installed on the controller
* SSH server installed/running on the managed node
* A user with `sudo` or root privileges
* SSH access between controller and managed node

For Ubuntu/Debian systems, update packages:

```bash
sudo apt update
```

Install OpenSSH server on the managed node if required:

```bash
sudo apt install openssh-server -y
```

Check SSH:

```bash
systemctl status ssh
```

---

# 3. Identify the Controller and Managed Node

In this example:

### Controller

```text
IP: 172.31.0.88
Hostname: ip-172-31-0-88
```

### Managed Node

```text
IP: 172.31.13.50
Hostname: ip-172-31-13-50
```

The controller will execute Ansible commands against the managed node.

---

# 4. Configure the Managed Node

Log in to the managed node:

```bash
ssh ubuntu@172.31.13.50
```

If using an AWS EC2 instance, use the EC2 key if required:

```bash
ssh -i /path/to/key.pem ubuntu@172.31.13.50
```

Become root:

```bash
sudo -i
```

---

# 5. Set Root Password

Set a password for the root user:

```bash
passwd root
```

Enter the new password when prompted.

> **Note:** Enabling root password SSH login is suitable for a lab environment, but is generally not recommended for production systems.

---

# 6. Configure SSH on the Managed Node

Edit the SSH configuration:

```bash
vi /etc/ssh/sshd_config
```

Set:

```text
PermitRootLogin yes
PasswordAuthentication yes
```

The important option names are case-sensitive.

Correct:

```text
PermitRootLogin yes
```

Not:

```text
permitrootlogin = yes
```

---

# 7. Check for SSH Configuration Overrides

Ubuntu may include additional SSH configuration files through:

```text
Include /etc/ssh/sshd_config.d/*.conf
```

Check for overriding settings:

```bash
grep -Rni "PasswordAuthentication" \
/etc/ssh/sshd_config \
/etc/ssh/sshd_config.d/
```

Also check the effective configuration:

```bash
sshd -T | grep -E 'permitrootlogin|passwordauthentication'
```

Expected:

```text
permitrootlogin yes
passwordauthentication yes
```

If the output says:

```text
passwordauthentication no
```

another SSH configuration file is overriding your setting.

Find and correct the file containing:

```text
PasswordAuthentication no
```

---

# 8. Validate SSH Configuration

Before restarting SSH, always validate the configuration:

```bash
sshd -t
```

If there is no output, the configuration syntax is valid.

Restart SSH:

```bash
systemctl restart ssh
```

Check the service:

```bash
systemctl status ssh
```

On systems where the service is named `sshd`:

```bash
systemctl restart sshd
systemctl status sshd
```

---

# 9. Test Root Password Login

From the Ansible controller:

```bash
ssh -o PubkeyAuthentication=no root@172.31.13.50
```

The option:

```text
-o PubkeyAuthentication=no
```

forces SSH to use password authentication instead of attempting the SSH key.

You should receive:

```text
root@172.31.13.50's password:
```

Enter the root password.

If successful, exit:

```bash
exit
```

---

# 10. Generate SSH Keys on the Controller

On the Ansible controller:

```bash
ssh-keygen
```

Press Enter to accept the default location.

The default files will be:

```text
/root/.ssh/id_ed25519
/root/.ssh/id_ed25519.pub
```

Check:

```bash
cd /root/.ssh
ls
```

Expected:

```text
authorized_keys
id_ed25519
id_ed25519.pub
known_hosts
```

The files have the following purpose:

| File              | Purpose                                   |
| ----------------- | ----------------------------------------- |
| `id_ed25519`      | Private SSH key                           |
| `id_ed25519.pub`  | Public SSH key                            |
| `known_hosts`     | Known SSH server keys                     |
| `authorized_keys` | Authorized public keys for the local user |

**Never share the private key `id_ed25519`.**

---

# 11. Copy the Controller Public Key to the Managed Node

From the controller:

```bash
ssh-copy-id root@172.31.13.50
```

You will initially be prompted for the root password.

Successful output looks similar to:

```text
Number of key(s) added: 1

Now try logging into the machine, with:

"ssh 'root@172.31.13.50'"
```

This means the controller's public key has been added to the managed node.

---

# 12. Test Passwordless SSH

From the controller:

```bash
ssh root@172.31.13.50
```

You should now be able to log in without entering the root password.

Exit:

```bash
exit
```

If passwordless SSH works, the SSH portion of the Ansible setup is ready.

---

# 13. Install Ansible on the Controller

On the controller:

```bash
apt update
apt install ansible -y
```

Check the installation:

```bash
ansible --version
```

Example:

```text
ansible [core ...]
```

---

# 14. Create the Ansible Inventory

Create the Ansible configuration directory if it doesn't exist:

```bash
mkdir -p /etc/ansible
```

Create the inventory:

```bash
vi /etc/ansible/hosts
```

Example:

```ini
[slaves]
slave1 ansible_host=172.31.13.50

[slaves:vars]
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
```

---

# 15. Understanding the Inventory

The following:

```ini
[slaves]
```

creates a host group called `slaves`.

This:

```ini
slave1 ansible_host=172.31.13.50
```

means:

* Ansible's hostname: `slave1`
* Actual server IP: `172.31.13.50`

This:

```ini
ansible_user=root
```

tells Ansible to connect using the `root` user.

This:

```ini
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
```

tells Ansible which private SSH key to use.

---

# 16. Multiple Managed Nodes

For multiple servers, the inventory can look like:

```ini
[slaves]
slave1 ansible_host=172.31.13.50
slave2 ansible_host=172.31.13.51
slave3 ansible_host=172.31.13.52

[slaves:vars]
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
```

Architecture:

```text
                         Controller
                         172.31.0.88
                              |
              ┌───────────────┼───────────────┐
              |               |               |
              ↓               ↓               ↓
           slave1          slave2          slave3
        172.31.13.50    172.31.13.51    172.31.13.52
```

---

# 17. Organizing Hosts into Groups

You can create different groups such as production and development:

```ini
[prod]
prod1 ansible_host=172.31.13.50
prod2 ansible_host=172.31.13.51

[dev]
dev1 ansible_host=172.31.13.52
dev2 ansible_host=172.31.13.53

[all:vars]
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
```

You can then target a specific group.

For production:

```bash
ansible prod -m ping
```

For development:

```bash
ansible dev -m ping
```

For all servers:

```bash
ansible all -m ping
```

---

# 18. Check the Inventory

List all hosts:

```bash
ansible all --list-hosts
```

Expected:

```text
hosts (1):
    slave1
```

For the slaves group:

```bash
ansible slaves --list-hosts
```

---

# 19. Test Ansible Connectivity

Run:

```bash
ansible all -m ping
```

Expected output:

```text
slave1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

This confirms:

1. Ansible can read the inventory.
2. The hostname/IP is correct.
3. SSH connectivity works.
4. The SSH key works.
5. The remote user is correct.
6. The managed node is reachable.

---

# 20. Test Remote Commands

Check the hostname:

```bash
ansible all -a "hostname"
```

Check uptime:

```bash
ansible all -a "uptime"
```

Check the remote user:

```bash
ansible all -a "whoami"
```

Expected:

```text
root
```

Check OS information:

```bash
ansible all -a "cat /etc/os-release"
```

---

# 21. Using `become`

Instead of connecting directly as root, a recommended production configuration is to use a normal administrative user and privilege escalation.

Example:

```yaml
---
- name: Example
  hosts: all
  become: true

  tasks:
    - name: Check current user
      command: whoami
```

With:

```yaml
become: true
```

Ansible can execute privileged commands using `sudo`.

For learning environments, connecting as root can be used, but it is less secure.

---

# 22. Example Ansible Playbook

Create a playbook:

```bash
mkdir -p /etc/ansible/playbooks
cd /etc/ansible/playbooks
vi uninstall-apache.yml
```

Playbook:

```yaml
---
- name: Uninstall Apache
  hosts: all
  become: true

  tasks:
    - name: Uninstall Apache
      apt:
        name: apache2
        state: absent

    - name: Print Message
      debug:
        msg: "Apache Uninstalled"
```

---

# 23. Run the Playbook

Run:

```bash
ansible-playbook uninstall-apache.yml
```

Ansible will:

1. Read `/etc/ansible/hosts`.
2. Find the `slaves`/`all` hosts.
3. Connect to the managed node using SSH.
4. Authenticate using `/root/.ssh/id_ed25519`.
5. Execute the tasks.
6. Uninstall Apache.

---

# 24. Check Apache Before Running

On the managed node:

```bash
systemctl status apache2
```

Or from the controller:

```bash
ansible all -a "systemctl status apache2"
```

---

# 25. Check Apache After Running

Run:

```bash
ansible all -a "dpkg -l apache2"
```

Or:

```bash
ansible all -a "systemctl status apache2"
```

If Apache was successfully removed, the service/package should no longer be available.

---

# 26. Useful Ansible Commands

### Test all hosts

```bash
ansible all -m ping
```

### Test only slaves

```bash
ansible slaves -m ping
```

### List inventory

```bash
ansible all --list-hosts
```

### Run a command

```bash
ansible all -a "uptime"
```

### Check hostname

```bash
ansible all -a "hostname"
```

### Check current user

```bash
ansible all -a "whoami"
```

### Run a playbook

```bash
ansible-playbook uninstall-apache.yml
```

### Dry-run/check mode

```bash
ansible-playbook uninstall-apache.yml --check
```

---

# 27. Troubleshooting

## Problem: Permission denied (publickey)

Example:

```text
Permission denied (publickey).
```

Check SSH manually:

```bash
ssh root@172.31.13.50
```

Check the key:

```bash
ls -l /root/.ssh/id_ed25519
ls -l /root/.ssh/id_ed25519.pub
```

Check the public key on the managed node:

```bash
cat /root/.ssh/authorized_keys
```

---

## Problem: `ssh-copy-id` fails

If:

```bash
ssh-copy-id root@172.31.13.50
```

returns:

```text
Permission denied (publickey).
```

the controller cannot perform the initial login.

First obtain access to the managed node using its existing SSH credentials, configure SSH/password authentication if appropriate for your lab, and then run:

```bash
ssh-copy-id root@172.31.13.50
```

---

## Problem: Password authentication says no

Check:

```bash
sshd -T | grep passwordauthentication
```

Expected:

```text
passwordauthentication yes
```

If you get:

```text
passwordauthentication no
```

search the included configuration files:

```bash
grep -Rni "PasswordAuthentication" \
/etc/ssh/sshd_config \
/etc/ssh/sshd_config.d/
```

Correct the overriding configuration.

---

## Problem: Root login is denied

Check:

```bash
sshd -T | grep permitrootlogin
```

For a lab configuration using root SSH login:

```text
permitrootlogin yes
```

---

## Problem: SSH configuration error

Run:

```bash
sshd -t
```

Fix any reported errors before restarting SSH.

---

## Problem: Ansible cannot connect

Run:

```bash
ansible all -m ping -vvv
```

The `-vvv` option provides detailed SSH/Ansible debugging information.

Also verify:

```bash
ssh root@172.31.13.50
```

If normal SSH does not work, fix SSH before troubleshooting Ansible.

---

# 28. Final Verification Checklist

Use the following checklist:

```text
[ ] Controller has Ansible installed
[ ] Managed node has SSH server installed
[ ] Controller can reach managed node
[ ] Root/admin account exists
[ ] SSH service is running
[ ] SSH configuration is valid
[ ] SSH key generated on controller
[ ] Public key copied to managed node
[ ] Passwordless SSH works
[ ] /etc/ansible/hosts exists
[ ] Managed node is present in inventory
[ ] ansible_user is configured
[ ] SSH private key path is correct
[ ] ansible all -m ping returns SUCCESS
[ ] Ansible playbook runs successfully
```

---

# 29. Final Configuration

### Controller

```text
IP: 172.31.0.88
SSH private key:
    /root/.ssh/id_ed25519

SSH public key:
    /root/.ssh/id_ed25519.pub

Inventory:
    /etc/ansible/hosts
```

### Managed Node

```text
IP: 172.31.13.50

SSH:
    Port 22

User:
    root

Authorized keys:
    /root/.ssh/authorized_keys
```

### Inventory

```ini
[slaves]
slave1 ansible_host=172.31.13.50

[slaves:vars]
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_ed25519
```

### Connectivity Test

```bash
ansible all -m ping
```

Expected:

```text
slave1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

# 30. Complete Workflow

The complete Ansible setup can be remembered as:

```text
1. Create Controller
          ↓
2. Create Managed Node
          ↓
3. Configure SSH on Managed Node
          ↓
4. Generate SSH key on Controller
          ↓
5. Copy public key to Managed Node
          ↓
6. Test passwordless SSH
          ↓
7. Install Ansible on Controller
          ↓
8. Create /etc/ansible/hosts
          ↓
9. Add Managed Node IP
          ↓
10. Run: ansible all -m ping
          ↓
11. Create Playbook
          ↓
12. Run: ansible-playbook playbook.yml
```

## Key Concept

Ansible does **not** need an Ansible agent installed on the managed node.

The controller communicates with Linux managed nodes primarily through **SSH**:

```text
Ansible Controller
        |
        | SSH + Private Key
        ↓
Managed Node
        |
        └── Executes Ansible commands/tasks
```

The inventory tells Ansible **which machines to connect to**, while the SSH configuration and keys determine **how Ansible authenticates to those machines**.