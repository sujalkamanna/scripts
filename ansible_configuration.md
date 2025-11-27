---

### **Step 1: Enable root login and password authentication on the slave**

1. Edit the SSH server configuration file on the slave:

```bash
sudo vi /etc/ssh/sshd_config
```

2. Make these changes:

```text
PermitRootLogin yes
PasswordAuthentication yes
```

3. Restart the SSH service:

```bash
sudo systemctl restart ssh
sudo sshd -t   # optional, checks syntax
```

---

### **Step 2: Set the root password on the slave**

1. On the slave:

```bash
sudo passwd root
```

* Enter the new password (we used the same as the master for convenience).

---

### **Step 3: Generate an SSH key pair on the master (if not already done)**

On the master:

```bash
ssh-keygen
```

* Save the key to `/root/.ssh/id_ed25519`.
* You can leave the passphrase empty for passwordless login.

---

### **Step 4: Copy the master’s public key to the slave**

1. Use `ssh-copy-id` with the slave IP:

```bash
ssh-copy-id root@<slave-IP>
```

* Enter the root password of the slave when prompted.
* This adds the master’s public key to `/root/.ssh/authorized_keys` on the slave.

---

### **Step 5: Verify passwordless SSH**

From the master:

```bash
ssh root@<slave-IP>
```

* You should now log in directly without being prompted for a password.

---

### **Step 6: Optional – Copy key to multiple slaves**

If you have multiple slave IPs:

```bash
for ip in 172.31.10.132 172.31.11.171 172.31.12.150; do
  ssh-copy-id root@$ip
done
```

* This loops through all slaves and installs the master’s public key.

---

### ✅ **What we achieved**

* Root login with password enabled temporarily.
* Root passwords synchronized with the master.
* Master’s SSH key copied to all slaves.
* Passwordless root SSH works from master to slave.
