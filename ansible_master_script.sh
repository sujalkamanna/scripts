# 1️⃣ Update system
sudo apt update -y
sudo apt upgrade -y

# 2️⃣ Install Python3
sudo apt install python3 -y

# 3️⃣ Install Ansible
sudo apt install ansible -y
ansible --version

# 4️⃣ Generate SSH key (press Enter for defaults, no passphrase)
ssh-keygen -t rsa -b 4096

# 5️⃣ Display public key to copy to Slave
cat ~/.ssh/id_rsa.pub

# 6️⃣ Create Ansible directory and hosts file
sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/hosts > /dev/null <<EOL
[slave_nodes]
slave1 ansible_host=<slave_IP> ansible_user=root
EOL

echo "After running this, copy the output of cat ~/.ssh/id_rsa.pub for the Slave."
#After running this, copy the output of cat ~/.ssh/id_rsa.pub for the Slave.
