# 📘 Complete Guide: Terraform & AWS CLI Setup for Beginners

## 🎯 What We're Building
- **AWS CLI**: A tool to manage AWS from your computer
- **Terraform**: A tool to create AWS resources using code
- **Secure Connection**: Safe way to let Terraform talk to AWS

---

## 📋 Table of Contents
1. [AWS Account Setup & Security](#-part-1--aws-account-setup--security)
2. [Install AWS CLI](#-part-2--install-aws-cli)
3. [Install Terraform](#-part-3--install-terraform)
4. [Connect Everything](#-part-4--connect-everything-together)
5. [Test Your Setup](#-part-5--test-your-setup)

---

## 🔐 Part 1 — AWS Account Setup & Security

### Step 1: Create an IAM User (Don't use root account!)

> ⚠️ **Security Best Practice**: Never use your root AWS account for daily tasks!

1. **Login to AWS Console** with your root account
2. **Go to IAM** (Identity and Access Management)
3. **Click "Users" → "Create user"**
4. **User details:**
   ```
   Username: terraform-user
   ✅ Provide user access to AWS Management Console (optional)
   ```

### Step 2: Create IAM Group with Permissions

> 💡 **Why Groups?** It's easier to manage permissions for multiple users

1. **Click "User groups" → "Create group"**
2. **Group name:** `terraform-developers`
3. **Attach policies** (start with these for learning):
   
   **For Learning/Testing Environment:**
   ```
   ✅ PowerUserAccess (can do most things except IAM)
   ```
   
   **For Production (More Secure):**
   ```
   ✅ AmazonEC2FullAccess
   ✅ AmazonS3FullAccess
   ✅ AmazonVPCFullAccess
   ✅ AmazonRDSFullAccess
   ```

4. **Add your user to this group**

### Step 3: Create Access Keys (Method 1 - Simple)

1. **Go to IAM → Users → terraform-user**
2. **Click "Security credentials" tab**
3. **Scroll to "Access keys" → "Create access key"**
4. **Select use case:** "Command Line Interface (CLI)"
5. **Download the CSV file** 
   
   > 🔒 **IMPORTANT**: 
   > - Save this file securely (password manager recommended)
   > - You'll NEVER see the secret key again
   > - Never commit these to Git!

**Your CSV contains:**
```
Access key ID: AWSACCESSKEYEXAMPLE
Secret access key: awssecretkey/00XXXXX/EXAMPLEKEY
```

### Step 4: Create IAM Role (Method 2 - More Secure for EC2)

> 💡 **Use this if** Terraform runs on an EC2 instance

1. **Go to IAM → Roles → Create role**
2. **Trusted entity:** AWS service → EC2
3. **Role name:** `terraform-ec2-role`
4. **Attach policies:** Same as above (PowerUserAccess or specific ones)
5. **Create role**

**Later, attach this role to your EC2 instance - no keys needed!**

---

## 💻 Part 2 — Install AWS CLI

### 🪟 For Windows Users

1. **Download installer:**
   ```
   https://awscli.amazonaws.com/AWSCLIV2.msi
   ```

2. **Double-click the MSI file** and follow the wizard
   
3. **Open Command Prompt** (Win+R, type `cmd`)
   
4. **Verify installation:**
   ```cmd
   aws --version
   ```
   You should see: `aws-cli/2.x.x`

### 🐧 For Linux Users

1. **Open Terminal**

2. **Run these commands:**
   ```bash
   # Install required tools
   sudo apt update
   sudo apt install -y curl unzip
   
   # Download AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   
   # Install
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Verify
   aws --version
   ```

---

## 🔧 Part 3 — Install Terraform

### 🪟 For Windows Users

1. **Download Terraform:**
   - Go to: https://www.terraform.io/downloads
   - Download: `Windows AMD64` (for most PCs)
   - You'll get a ZIP file

2. **Setup Terraform:**
   ```
   a. Create folder: C:\terraform
   b. Extract terraform.exe to C:\terraform\
   c. Add to PATH (run as Administrator):
   ```
   ```cmd
   setx /M PATH "%PATH%;C:\terraform"
   ```

3. **Close and reopen Command Prompt**

4. **Verify:**
   ```cmd
   terraform --version
   ```

### 🐧 For Linux Users

**Easy Method:**
```bash
# Download (check latest version at terraform.io)
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip

# Unzip
unzip terraform_1.5.7_linux_amd64.zip

# Move to system path
sudo mv terraform /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/terraform

# Verify
terraform --version
```

---

## 🔗 Part 4 — Connect Everything Together

### Method A: Configure AWS CLI (Recommended for Beginners)

1. **Open Terminal/Command Prompt**

2. **Run:**
   ```bash
   aws configure
   ```

3. **Enter your details:**
   ```
   AWS Access Key ID: [paste from CSV]
   AWS Secret Access Key: [paste from CSV]
   Default region name: us-east-1
   Default output format: json
   ```

4. **This creates files:**
   - Windows: `C:\Users\YourName\.aws\credentials`
   - Linux: `~/.aws/credentials`

### Method B: Use Environment Variables (Good for CI/CD)

**Windows:**
```cmd
setx AWS_ACCESS_KEY_ID "AWSACCESSKEYEXAMPLE"
setx AWS_SECRET_ACCESS_KEY "awssecretkey/00XXXXX/EXAMPLEKEY"
setx AWS_DEFAULT_REGION "us-east-1"
```

**Linux:**
```bash
export AWS_ACCESS_KEY_ID="AWSACCESSKEYEXAMPLE"
export AWS_SECRET_ACCESS_KEY="awssecretkey/00XXXXX/EXAMPLEKEY"
export AWS_DEFAULT_REGION="us-east-1"
```

### Method C: Using IAM Roles (Best for EC2)

If running on EC2, just attach the role we created earlier - no configuration needed!

---

## 🧪 Part 5 — Test Your Setup

### Create Your First Terraform File

1. **Create a new folder:** `my-first-terraform`

2. **Create file:** `main.tf`
   ```hcl
   # Configure AWS Provider
   provider "aws" {
     region = "us-east-1"
   }
   
   # Create a simple S3 bucket
   resource "aws_s3_bucket" "my_first_bucket" {
     bucket = "my-terraform-test-bucket-${random_id.bucket_id.hex}"
   }
   
   # Generate random ID for unique bucket name
   resource "random_id" "bucket_id" {
     byte_length = 8
   }
   
   # Output the bucket name
   output "bucket_name" {
     value = aws_s3_bucket.my_first_bucket.id
   }
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Preview changes:**
   ```bash
   terraform plan
   ```

5. **Create resources:**
   ```bash
   terraform apply
   ```
   Type `yes` when prompted

6. **Clean up (delete resources):**
   ```bash
   terraform destroy
   ```
   Type `yes` when prompted

---

## 🛡️ Security Best Practices Summary

### ✅ DO's:
1. **Use IAM users**, never root account
2. **Enable MFA** (Multi-Factor Authentication) on your AWS account
3. **Use IAM roles** when running on EC2
4. **Rotate access keys** every 90 days
5. **Use least privilege** - only give permissions needed
6. **Store secrets in password managers**
7. **Use `.gitignore`** to exclude credentials:
   ```gitignore
   # .gitignore file
   *.tfvars
   .terraform/
   .aws/
   *.pem
   *.key
   ```

### ❌ DON'Ts:
1. **Never commit** AWS keys to Git
2. **Never share** access keys via email/Slack
3. **Never use** PowerUserAccess in production
4. **Never hardcode** credentials in Terraform files

---

## 🚨 Troubleshooting

### "terraform: command not found"
- **Windows**: Restart Command Prompt after adding to PATH
- **Linux**: Check if `/usr/local/bin` is in PATH: `echo $PATH`

### "AWS credentials not found"
- Run `aws configure list` to check current configuration
- Ensure credentials file exists in correct location

### "Access Denied" errors
- Check IAM user has necessary permissions
- Verify you're in the correct AWS region

---

## 📚 What's Next?

1. **Learn Terraform basics**: Start with simple resources (S3, EC2)
2. **Use Terraform modules**: Reusable code blocks
3. **Implement state management**: Use S3 backend for team collaboration
4. **Add terraform fmt**: Format your code consistently
5. **Use terraform validate**: Check syntax before applying

---
