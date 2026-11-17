
#!/bin/bash

# ==========================================
# ANSIBLE SLAVE / MANAGED NODE SETUP
# Ubuntu on AWS EC2
# ==========================================

# 1. Update system
sudo apt update -y
sudo apt upgrade -y

# 2. Install Python3
sudo apt install -y python3

# 3. Ensure OpenSSH Server is installed
sudo apt install -y openssh-server

# 4. Enable and start SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# 5. Create .ssh directory
sudo mkdir -p /home/ubuntu/.ssh

# Set correct ownership and permissions
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh
sudo chmod 700 /home/ubuntu/.ssh

# ==========================================
# 6. ADD MASTER PUBLIC KEY
# ==========================================

echo ""
echo "Paste the Master's public key below."
echo "Then press CTRL+D"
echo ""

sudo tee -a /home/ubuntu/.ssh/authorized_keys > /dev/null

# ==========================================
# 7. FIX PERMISSIONS
# ==========================================

sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys

# 8. Restart SSH
sudo systemctl restart ssh

# 9. Verify SSH service
sudo systemctl is-active ssh

echo "=========================================="
echo "SLAVE SETUP COMPLETE"
echo "=========================================="
