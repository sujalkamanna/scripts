# 📘 Complete Guide: Terraform & AWS CLI Setup for Beginners

## 🎯 What We're Building
- **AWS CLI**: A tool to manage AWS from your computer
- **Terraform**: A tool to create AWS resources using code
- **Secure Connection**: Safe way to let Terraform talk to AWS
- **Remote State**: Store Terraform state safely in AWS (S3 + DynamoDB)
- **Import Existing Resources**: Bring AWS Console-created resources into Terraform

---

## 📋 Table of Contents
1. [AWS Account Setup & Security](#-part-1--aws-account-setup--security)
2. [Install AWS CLI](#-part-2--install-aws-cli)
3. [Install Terraform](#-part-3--install-terraform)
4. [Connect Everything](#-part-4--connect-everything-together)
5. [Setup Remote State (S3 + DynamoDB)](#-part-5--setup-remote-state-storage)
6. [Import Existing AWS Resources](#-part-6--import-existing-aws-resources)
7. [Test Your Setup](#-part-7--test-your-setup)

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
   ✅ AmazonDynamoDBFullAccess (needed for state locking)
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
Access key ID: AKIAIOSFODNN7EXAMPLE
Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
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
setx AWS_ACCESS_KEY_ID "AKIAIOSFODNN7EXAMPLE"
setx AWS_SECRET_ACCESS_KEY "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
setx AWS_DEFAULT_REGION "us-east-1"
```

**Linux:**
```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="us-east-1"
```

### Method C: Using IAM Roles (Best for EC2)

If running on EC2, just attach the role we created earlier - no configuration needed!

---

## 🗄️ Part 5 — Setup Remote State Storage

### Why Remote State?

> 💡 **The Problem with Local State:**
> - Default: Terraform stores state in `terraform.tfstate` file locally
> - **Issues**: Can't share with team, easy to lose, no locking (conflicts)

> ✅ **The Solution - Remote State:**
> - **S3**: Stores state file securely in cloud
> - **DynamoDB**: Prevents conflicts when multiple people work together (state locking)

---

### Step 1: Create S3 Bucket for State Files

#### Option A: Using AWS Console (Visual)

1. **Go to AWS Console → S3**
2. **Click "Create bucket"**
3. **Configure:**
   ```
   Bucket name: my-terraform-state-bucket-2024
   Region: us-east-1
   
   Block Public Access:
   ✅ Block all public access (IMPORTANT!)
   
   Bucket Versioning:
   ✅ Enable (to keep history of state files)
   
   Encryption:
   ✅ Enable Server-side encryption (SSE-S3)
   ```
4. **Click "Create bucket"**

#### Option B: Using AWS CLI (Faster)

```bash
# Create bucket with versioning and encryption
aws s3api create-bucket \
  --bucket my-terraform-state-bucket-2024 \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket-2024 \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket-2024 \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket my-terraform-state-bucket-2024 \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

---

### Step 2: Create DynamoDB Table for State Locking

#### Option A: Using AWS Console

1. **Go to AWS Console → DynamoDB**
2. **Click "Create table"**
3. **Configure:**
   ```
   Table name: terraform-state-lock
   Partition key: LockID (type: String)
   
   Table settings: Use default settings
   
   Read/write capacity: On-demand (easiest, pay-per-use)
   ```
4. **Click "Create table"**

#### Option B: Using AWS CLI

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

---

### Step 3: Configure Terraform to Use Remote State

#### Create Backend Configuration File

**Create file: `backend.tf`**

```hcl
# backend.tf - Remote state configuration

terraform {
  backend "s3" {
    # S3 bucket for storing state
    bucket = "my-terraform-state-bucket-2024"
    
    # Path within bucket (organize by project)
    key    = "project-name/terraform.tfstate"
    
    # AWS region
    region = "us-east-1"
    
    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-lock"
    
    # Enable encryption at rest
    encrypt = true
    
    # Optional: Use specific AWS profile
    # profile = "terraform-user"
  }
}
```

---

### Step 4: Initialize Remote Backend

```bash
# Navigate to your Terraform project folder
cd my-terraform-project

# Initialize - Terraform will setup remote backend
terraform init

# If migrating from local state, Terraform will ask:
# "Do you want to copy existing state to the new backend?"
# Type: yes
```

**You'll see:**
```
Initializing the backend...

Successfully configured the backend "s3"!
```

---

## 🔄 Part 6 — Import Existing AWS Resources

### Why Import Resources?

> 🤔 **Common Scenario:**
> - You created resources manually using AWS Console
> - Now you want to manage them with Terraform
> - **Solution**: Import them into Terraform state

---

### Understanding the Import Process

**The import process has 3 steps:**

1. **Write Terraform code** for the resource (empty configuration)
2. **Import the resource** into state using its ID
3. **Update the code** to match actual resource configuration

> ⚠️ **Important**: Import only brings resources into state - you still need to write the code!

---

### Method 1: Manual Import (Traditional Way)

#### Example 1: Import an Existing S3 Bucket

**Scenario:** You created bucket `my-existing-bucket` in AWS Console

**Step 1: Find the Resource ID**

```bash
# List all S3 buckets to find the name
aws s3 ls

# Output:
# 2024-01-01 10:00:00 my-existing-bucket
# 2024-01-02 11:00:00 another-bucket
```

**Step 2: Write Empty Terraform Configuration**

Create `imported-resources.tf`:

```hcl
# imported-resources.tf

# Empty resource block - we'll fill this later
resource "aws_s3_bucket" "imported_bucket" {
  # Bucket name is required
  bucket = "my-existing-bucket"
  
  # We'll add other settings after import
}
```

**Step 3: Import the Resource**

```bash
# Syntax: terraform import <resource_type>.<resource_name> <resource_id>
terraform import aws_s3_bucket.imported_bucket my-existing-bucket
```

**You'll see:**
```
aws_s3_bucket.imported_bucket: Importing from ID "my-existing-bucket"...
aws_s3_bucket.imported_bucket: Import complete!
  Imported aws_s3_bucket (ID: my-existing-bucket)
```

**Step 4: Get Current Configuration**

```bash
# Show the imported resource's current state
terraform state show aws_s3_bucket.imported_bucket
```

**Output:**
```hcl
# aws_s3_bucket.imported_bucket:
resource "aws_s3_bucket" "imported_bucket" {
    arn                         = "arn:aws:s3:::my-existing-bucket"
    bucket                      = "my-existing-bucket"
    bucket_domain_name          = "my-existing-bucket.s3.amazonaws.com"
    id                          = "my-existing-bucket"
    region                      = "us-east-1"
    
    versioning {
        enabled    = true
        mfa_delete = false
    }
    
    tags = {
        Environment = "Production"
        ManagedBy   = "Manual"
    }
}
```

**Step 5: Update Your Terraform Code**

Copy the configuration from `state show` and update your file:

```hcl
# imported-resources.tf

resource "aws_s3_bucket" "imported_bucket" {
  bucket = "my-existing-bucket"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"  # Updated!
  }
}

# Versioning is now a separate resource in newer Terraform
resource "aws_s3_bucket_versioning" "imported_bucket_versioning" {
  bucket = aws_s3_bucket.imported_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

**Step 6: Verify No Changes**

```bash
terraform plan
```

**Expected output:**
```
No changes. Your infrastructure matches the configuration.
```

---

#### Example 2: Import an EC2 Instance

**Step 1: Find Instance ID**

```bash
# List EC2 instances
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' \
  --output table

# Output:
# |  i-0123456789abcdef0  |  WebServer  |  running  |
```

**Step 2: Write Configuration**

```hcl
# imported-resources.tf

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # We'll update this
  instance_type = "t2.micro"                # We'll update this
  
  tags = {
    Name = "WebServer"
  }
}
```

**Step 3: Import**

```bash
terraform import aws_instance.web_server i-0123456789abcdef0
```

**Step 4: Get Full Configuration**

```bash
terraform state show aws_instance.web_server
```

**Step 5: Update Code with Real Values**

```hcl
resource "aws_instance" "web_server" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = ["sg-0123456789abcdef0"]
  subnet_id              = "subnet-0123456789abcdef0"
  
  tags = {
    Name        = "WebServer"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

---

### Method 2: Using Import Blocks (Terraform 1.5+)

> ✨ **New in Terraform 1.5**: Import blocks make importing easier!

**Example: Import S3 Bucket with Import Block**

```hcl
# import.tf

# Define what to import
import {
  to = aws_s3_bucket.imported_bucket
  id = "my-existing-bucket"
}

# Resource configuration
resource "aws_s3_bucket" "imported_bucket" {
  bucket = "my-existing-bucket"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

**Run:**
```bash
# Plan shows what will be imported
terraform plan

# Apply imports the resource
terraform apply
```

---

### Method 3: Using Terraform Tools for Bulk Import

#### Tool 1: terraform-import (Community Tool)

**Install:**
```bash
# Using Go
go install github.com/GoogleCloudPlatform/terraformer@latest
```

**Use Terraformer to import all S3 buckets:**
```bash
terraformer import aws --resources=s3 --regions=us-east-1
```

#### Tool 2: Former2 (Generate Terraform from Console)

1. **Install Former2 Chrome Extension**
   - Visit: https://former2.com/
   - Click "Launch Web App" or install browser extension

2. **Scan Your AWS Account**
   - Former2 scans resources in your AWS account
   - Generates Terraform code automatically

3. **Export Terraform Code**
   - Select resources to export
   - Download `.tf` files

---

### Complete Import Workflow Example

**Scenario:** Import existing VPC, subnet, and security group

**Step 1: List Resources**

```bash
# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table

# List Subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,VpcId,CidrBlock]' --output table

# List Security Groups
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,VpcId]' --output table
```

**Step 2: Create Import File**

```hcl
# imports.tf

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Main VPC"
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "Public Subnet"
  }
}

# Security Group
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id
  
  tags = {
    Name = "Web Security Group"
  }
}
```

**Step 3: Import Resources**

```bash
# Import VPC
terraform import aws_vpc.main vpc-0123456789abcdef0

# Import Subnet
terraform import aws_subnet.public subnet-0123456789abcdef0

# Import Security Group
terraform import aws_security_group.web sg-0123456789abcdef0
```

**Step 4: Get Configuration Details**

```bash
# Show each resource
terraform state show aws_vpc.main
terraform state show aws_subnet.public
terraform state show aws_security_group.web
```

**Step 5: Update Configuration**

```hcl
# Complete configuration based on state show output

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name      = "Main VPC"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name      = "Public Subnet"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name      = "Web Security Group"
    ManagedBy = "Terraform"
  }
}
```

**Step 6: Verify**

```bash
terraform plan
# Should show: No changes
```

---

### Quick Reference: Common Resource IDs

| Resource Type | ID Format | How to Find |
|--------------|-----------|-------------|
| S3 Bucket | `bucket-name` | `aws s3 ls` |
| EC2 Instance | `i-0123456789abcdef0` | `aws ec2 describe-instances` |
| VPC | `vpc-0123456789abcdef0` | `aws ec2 describe-vpcs` |
| Subnet | `subnet-0123456789abcdef0` | `aws ec2 describe-subnets` |
| Security Group | `sg-0123456789abcdef0` | `aws ec2 describe-security-groups` |
| IAM User | `username` | `aws iam list-users` |
| IAM Role | `role-name` | `aws iam list-roles` |
| RDS Instance | `db-instance-id` | `aws rds describe-db-instances` |
| Lambda Function | `function-name` | `aws lambda list-functions` |

---

### Import Script for Multiple Resources

**Create `import-script.sh`:**

```bash
#!/bin/bash

# Import script for multiple resources

echo "Starting import process..."

# Import VPC
echo "Importing VPC..."
terraform import aws_vpc.main vpc-0123456789abcdef0

# Import Subnets
echo "Importing subnets..."
terraform import aws_subnet.public_1 subnet-0123456789abcdef0
terraform import aws_subnet.public_2 subnet-1123456789abcdef0

# Import Security Groups
echo "Importing security groups..."
terraform import aws_security_group.web sg-0123456789abcdef0
terraform import aws_security_group.database sg-1123456789abcdef0

# Import EC2 Instances
echo "Importing EC2 instances..."
terraform import aws_instance.web_server_1 i-0123456789abcdef0
terraform import aws_instance.web_server_2 i-1123456789abcdef0

echo "Import complete! Run 'terraform plan' to verify."
```

**Make executable and run:**
```bash
chmod +x import-script.sh
./import-script.sh
```

---

### Troubleshooting Import Issues

#### Error: "Resource already exists in state"

```bash
# Remove from state first
terraform state rm aws_s3_bucket.imported_bucket

# Then import again
terraform import aws_s3_bucket.imported_bucket my-existing-bucket
```

#### Error: "Cannot import non-existent resource"

```bash
# Verify resource exists in AWS
aws s3 ls | grep my-bucket

# Check you're using correct region
aws configure get region

# Try specifying region explicitly
AWS_DEFAULT_REGION=us-east-1 terraform import aws_s3_bucket.imported_bucket my-existing-bucket
```

#### After Import: Plan Shows Many Changes

This means your Terraform code doesn't match the actual resource.

**Solution:**
```bash
# Get the exact configuration
terraform state show aws_s3_bucket.imported_bucket > current-config.txt

# Update your .tf file to match
# Then run plan again
terraform plan
```

---

## 🧪 Part 7 — Test Your Setup

### Test 1: Verify Remote State

```bash
# Check where state is stored
terraform state list

# Pull remote state to see it
terraform state pull
```

**Check S3 bucket in AWS Console:**
- You should see the state file at the path you specified
- With versioning enabled, you can see previous versions

### Test 2: Test State Locking

**Open two terminals and try running `terraform apply` in both:**

```bash
# Terminal 1
terraform apply

# Terminal 2 (while terminal 1 is running)
terraform apply
```

**You'll see in Terminal 2:**
```
Error: Error acquiring the state lock

Error message: ConditionalCheckFailedException: The conditional 
request failed
Lock Info:
  ID:        abc123-def456...
  Path:      my-terraform-state-bucket-2024/dev/my-app/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.5.7
  Created:   2024-01-15 10:30:00 UTC
```

> ✅ **This is GOOD!** It means locking is working and preventing conflicts.

### Test 3: Test Import Workflow

**Create a test resource in AWS Console:**

1. **Go to S3 → Create bucket**
   - Name: `test-import-bucket-yourname`
   - Region: us-east-1
   - Create

2. **Import it into Terraform:**

```bash
# Create config file
cat > test-import.tf << 'EOF'
resource "aws_s3_bucket" "test_import" {
  bucket = "test-import-bucket-yourname"
}
EOF

# Import
terraform import aws_s3_bucket.test_import test-import-bucket-yourname

# Verify
terraform state list
terraform plan
```

3. **Clean up:**

```bash
# Destroy using Terraform (now it's managed!)
terraform destroy -target=aws_s3_bucket.test_import
```

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
   *.tfstate
   *.tfstate.backup
   .terraform/
   .aws/
   *.pem
   *.key
   override.tf
   override.tf.json
   ```
8. **Enable S3 versioning** for state files
9. **Use DynamoDB locking** to prevent conflicts
10. **Document imported resources** in comments

### ❌ DON'Ts:

1. **Never commit** AWS keys to Git
2. **Never share** access keys via email/Slack
3. **Never use** PowerUserAccess in production
4. **Never hardcode** credentials in Terraform files
5. **Never manually edit** state files (use `terraform state` commands)
6. **Never delete** DynamoDB lock table while Terraform is running
7. **Don't import without writing code first**

---

## 📊 Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────┐
│           TERRAFORM WORKFLOW                        │
└─────────────────────────────────────────────────────┘

1. NEW RESOURCES (Create with Terraform)
   ↓
   Write .tf files → terraform plan → terraform apply
   ↓
   Resources created in AWS + State stored in S3

2. EXISTING RESOURCES (Import from Console)
   ↓
   Find Resource ID → Write empty .tf → terraform import
   ↓
   terraform state show → Update .tf to match
   ↓
   terraform plan (should show no changes)

3. MODIFY RESOURCES
   ↓
   Edit .tf files → terraform plan → terraform apply
   ↓
   Changes applied + State updated in S3

4. DELETE RESOURCES
   ↓
   terraform destroy → Resources deleted
   ↓
   State updated in S3
```

---

## 📚 Cheat Sheet

### Essential Commands

```bash
# Initialize project
terraform init

# View execution plan
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_s3_bucket.example

# Import existing resource
terraform import aws_s3_bucket.example bucket-name

# Remove resource from state (doesn't delete in AWS)
terraform state rm aws_s3_bucket.example

# Force unlock state
terraform force-unlock <LOCK_ID>

# Refresh state from AWS
terraform refresh

# Target specific resource
terraform apply -target=aws_s3_bucket.example

# Use specific var file
terraform apply -var-file=production.tfvars
```

### AWS CLI Commands for Finding Resources

```bash
# S3 Buckets
aws s3 ls

# EC2 Instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# Subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,VpcId,CidrBlock,AvailabilityZone]' --output table

# Security Groups
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,VpcId]' --output table

# RDS Instances
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,Engine]' --output table

# Lambda Functions
aws lambda list-functions --query 'Functions[*].[FunctionName,Runtime]' --output table

# IAM Users
aws iam list-users --query 'Users[*].[UserName,CreateDate]' --output table

# IAM Roles
aws iam list-roles --query 'Roles[*].[RoleName,CreateDate]' --output table
```

---

## 🎉 Congratulations!

You now have a **complete Terraform setup** with:
- ✅ Secure AWS authentication
- ✅ Remote state storage in S3
- ✅ State locking with DynamoDB
- ✅ Ability to import existing resources
- ✅ Team collaboration ready
- ✅ Version control safe
- ✅ Production-ready workflows

**Happy Infrastructure as Code! 🚀**

---

## 📖 Additional Resources

- **Terraform Documentation**: https://www.terraform.io/docs
- **AWS Provider Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Terraform Import Guide**: https://www.terraform.io/docs/import
- **Former2 Tool**: https://former2.com
- **Terraformer Tool**: https://github.com/GoogleCloudPlatform/terraformer
- **Learn Terraform**: https://learn.hashicorp.com/terraform
