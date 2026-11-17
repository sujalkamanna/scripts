# ==========================================
# ANSIBLE MASTER / CONTROLLER SETUP
# Ubuntu on AWS EC2
# ==========================================

# 1. Update system packages
sudo apt update -y
sudo apt upgrade -y

# 2. Install Python3
sudo apt install -y python3

# 3. Install Ansible
sudo apt install -y ansible

# Verify Ansible installation
echo "=========================================="
echo "ANSIBLE VERSION"
echo "=========================================="
ansible --version


# ==========================================
# 4. SET UP SSH KEY FOR THE UBUNTU USER
# ==========================================

# Create .ssh directory if it does not exist
sudo mkdir -p /home/ubuntu/.ssh

# Set correct ownership and permissions
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh
sudo chmod 700 /home/ubuntu/.ssh


# Generate SSH key ONLY if it does not already exist
if [ ! -f /home/ubuntu/.ssh/id_rsa ]; then

    echo "Generating SSH key for ubuntu user..."

    sudo -u ubuntu ssh-keygen \
        -t rsa \
        -b 4096 \
        -f /home/ubuntu/.ssh/id_rsa \
        -N ""

else

    echo "SSH key already exists."
    echo "Existing key will NOT be overwritten."

fi


# ==========================================
# 5. DISPLAY MASTER PUBLIC KEY
# ==========================================

echo ""
echo "=========================================="
echo "COPY THIS PUBLIC KEY"
echo "ADD IT TO EVERY SLAVE'S:"
echo "/home/ubuntu/.ssh/authorized_keys"
echo "=========================================="

sudo cat /home/ubuntu/.ssh/id_rsa.pub


# ==========================================
# 6. CREATE ANSIBLE INVENTORY
# ==========================================

sudo mkdir -p /etc/ansible

sudo tee /etc/ansible/hosts > /dev/null <<'EOL'
[slave_nodes]

# Add your Slave / Managed Nodes below

slave1 ansible_host=172.31.33.205

# Example additional nodes:
# slave2 ansible_host=172.31.4.10
# slave3 ansible_host=172.31.5.20


[slave_nodes:vars]

ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3

EOL


# ==========================================
# 7. SET INVENTORY PERMISSIONS
# ==========================================

sudo chmod 644 /etc/ansible/hosts


# ==========================================
# 8. VERIFY INVENTORY
# ==========================================

echo ""
echo "=========================================="
echo "ANSIBLE INVENTORY"
echo "=========================================="

ansible-inventory --list --yaml


# ==========================================
# SETUP COMPLETE
# ==========================================

echo ""
echo "=========================================="
echo "MASTER SETUP COMPLETE"
echo "=========================================="

echo "Next steps:"
echo ""
echo "1. Copy the public key displayed above."
echo ""
echo "2. Add it to every Slave:"
echo "   /home/ubuntu/.ssh/authorized_keys"
echo ""
echo "3. Make sure each Slave allows SSH (Port 22)"
echo "   from the Master EC2 Security Group."
echo ""
echo "4. Test SSH from the Master:"
echo "   ssh -i /home/ubuntu/.ssh/id_rsa ubuntu@<SLAVE_PRIVATE_IP>"
echo ""
echo "5. Test Ansible:"
echo "   ansible all -m ping"
echo ""