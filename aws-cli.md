# **Installing AWS CLI on AWS EC2 (with Access Keys Setup)**

### **Step 0: Prerequisites**

* EC2 instance (**Windows Server** or **Linux**)
* Internet access to download AWS CLI
* IAM user with programmatic access (to generate access keys) **or IAM role attached to EC2**

---

# **For Ubuntu / Debian EC2**

### **Step 1: Update System Packages**

```bash
sudo apt-get update -y
sudo apt-get upgrade -y
```

---

### **Step 2: Download and Install AWS CLI v2**

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

---

### **Step 3: Verify Installation**

```bash
aws --version
```

Expected output:

```text
aws-cli/2.x.x Python/3.x Linux/...
```

---

### **Step 4: Create AWS Access Keys**

> **Option 1: Using AWS Management Console (recommended)**

1. Login to AWS Console
2. Go to **IAM → Users → [Select User] → Security Credentials**
3. Click **Create Access Key**
4. Download or copy the **Access Key ID** and **Secret Access Key**

> Keep these credentials safe. Treat them like a password.

---

> **Option 2: Using AWS CLI (if another admin user is configured)**

```bash
aws iam create-access-key --user-name <username>
```

Example output:

```json
{
    "AccessKey": {
        "UserName": "dev-user",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "Status": "Active",
        "CreateDate": "2026-01-04T10:00:00Z"
    }
}
```

> **Important:** Save `AccessKeyId` and `SecretAccessKey` securely.

---

### **Step 5: Configure AWS CLI with Access Keys**

```bash
aws configure
```

Enter:

* **AWS Access Key ID:** `AWSACCESSKEYEXAMPLE`
* **AWS Secret Access Key:** `awssecret/acsesskey/EXAMPLEKEY`
* **Default region name:** e.g., `your-region`
* **Default output format:** e.g., `json`

> This will create the configuration at `~/.aws/credentials` and `~/.aws/config`.

---

### **Step 6: Test AWS CLI**

```bash
# List S3 buckets (if you have created)
aws s3 ls

# Check EC2 instances
aws ec2 describe-instances
```

If the EC2 instance has **an IAM role**, AWS CLI will automatically use its role credentials, and you **don’t need access keys**.( Attach required permissions)

---

# **For Windows Server EC2**

### **Step 1: Open PowerShell as Administrator**

Search for **PowerShell**, right-click and select **Run as Administrator**.

---

### **Step 2: Download and Install AWS CLI v2**

Using PowerShell:

```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /qn
```

Alternatively:

1. Download AWSCLIV2.msi
2. Run the installer
3. Complete the installation wizard

---

### **Step 3: Verify Installation**

Open a new PowerShell window and run:

```powershell
aws --version
```

Expected output:

```text
aws-cli/2.x.x Python/3.x Windows/...
```

---

### **Step 4: Create AWS Access Keys**

> **Option 1: Using AWS Management Console (recommended)**

1. Login to AWS Console
2. Go to **IAM → Users → [Select User] → Security Credentials**
3. Click **Create Access Key**
4. Download or copy the **Access Key ID** and **Secret Access Key**

> Keep these credentials safe. Treat them like a password.

---

> **Option 2: Using AWS CLI (if another admin user is configured)**

```powershell
aws iam create-access-key --user-name <username>
```

Example output:

```json
{
    "AccessKey": {
        "UserName": "dev-user",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "Status": "Active",
        "CreateDate": "2026-01-04T10:00:00Z"
    }
}
```

> **Important:** Save `AccessKeyId` and `SecretAccessKey` securely.

---

### **Step 5: Configure AWS CLI with Access Keys**

```powershell
aws configure
```

Enter:

* **AWS Access Key ID:** `AWSACCESSKEYEXAMPLE`
* **AWS Secret Access Key:** `awssecret/acsesskey/EXAMPLEKEY`
* **Default region name:** e.g., `your-region`
* **Default output format:** e.g., `json`

> This will create the configuration at:

```text
C:\Users\<username>\.aws\credentials
C:\Users\<username>\.aws\config
```

---

### **Step 6: Test AWS CLI**

```powershell
# List S3 buckets (if you have created)
aws s3 ls

# Check EC2 instances
aws ec2 describe-instances
```

If the EC2 instance has **an IAM role**, AWS CLI will automatically use its role credentials, and you **don’t need access keys**.

---

### ✅ **Optional Security Tip**

* Never commit AWS keys to GitHub or scripts.
* Prefer **IAM roles for EC2** whenever possible.
* Rotate keys periodically for security.

---