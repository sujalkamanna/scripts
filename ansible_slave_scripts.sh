# 1️⃣ Update system
sudo apt update -y
sudo apt upgrade -y

# 2️⃣ Install Python3
sudo apt install python3 -y

# 3️⃣ Ensure SSH is running
sudo systemctl enable ssh
sudo systemctl start ssh

# 4️⃣ Add Master’s public key for passwordless SSH
mkdir -p /root/.ssh
nano /root/.ssh/authorized_keys
# Paste the Master public key here and save
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
