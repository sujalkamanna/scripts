Here is the raw Markdown content. You can copy everything inside the code block below and paste it directly into a file named `README.md` or `install_guide.md`.

```markdown
# Terraform & AWS CLI Installation Guide (Windows)

This document provides step-by-step instructions to install **AWS CLI** and **Terraform** on **Windows (ARM64 / AMD64)**, configure system environment variables, and verify the installation using command-line tools.

---

## Prerequisites
- Windows 10 / 11 (64-bit)
- Administrator access
- Internet connectivity

---

## 1. Install or Update AWS CLI (Required for Terraform + AWS)

Terraform uses AWS credentials managed by the AWS CLI, so install AWS CLI first.

### 1.1 Download AWS CLI Installer (Windows 64-bit)

Download and run the AWS CLI MSI installer:

[https://awscli.amazonaws.com/AWSCLIV2.msi](https://awscli.amazonaws.com/AWSCLIV2.msi)

### 1.2 Install AWS CLI Using Command Line (Optional)

Open **Command Prompt as Administrator** and run:

```cmd
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

This command installs or updates AWS CLI by overwriting any previous version.

### 1.3 Verify AWS CLI Installation

```cmd
aws --version
```

Expected output:

```text
aws-cli/2.x.x Python/3.x Windows/...
```

---

## 2. Install Terraform (Windows)

### 2.1 Download Terraform

Visit the official download page:

[https://developer.hashicorp.com/terraform/install#windows](https://developer.hashicorp.com/terraform/install#windows)

Download the appropriate version:
* **ARM64** – for ARM-based systems
* **AMD64** – for Intel/AMD systems

### 2.2 Extract Terraform

1. Extract the downloaded ZIP file.
2. Move `terraform.exe` to a permanent location.

**Example directory:**

```text
C:\terraform\
    terraform.exe
```

---

## 3. Add Terraform to System PATH (GUI Method)

1. Press **Win + R**.
2. Type:
   ```cmd
   sysdm.cpl
   ```
3. Go to the **Advanced** tab.
4. Click **Environment Variables**.
5. Under **System variables**, select **Path**.
6. Click **Edit**.
7. Click **New**.
8. Add:
   ```text
   C:\terraform
   ```
9. Click **OK → OK → OK**.

✅ Terraform is now available system-wide.

---

## 4. Verify Terraform Installation

Open **Command Prompt** or **PowerShell**:

```cmd
terraform -version
```

Expected output:

```text
Terraform vX.Y.Z
```

---

## 5. Add Terraform to PATH Using Command Line (Alternative)

Use this method if you prefer command-line configuration instead of the GUI.

### 5.1 Temporary PATH (Current Session Only)

```cmd
set PATH=%PATH%;C:\terraform
```

### 5.2 Permanent PATH (System-Wide)

Open **Command Prompt as Administrator**:

```cmd
setx /M PATH "%PATH%;C:\terraform"
```

⚠️ **Note:** Close and reopen the terminal after running this command for changes to take effect.

---

## 6. Validate Terraform Path

To ensure the system is finding the correct executable:

```cmd
where terraform
```

Expected output:

```text
C:\terraform\terraform.exe
```

---

## 7. Summary Commands

| Task | Command |
| :--- | :--- |
| **Verify AWS CLI** | `aws --version` |
| **Verify Terraform** | `terraform -version` |
| **Set PATH (temporary)** | `set PATH=%PATH%;C:\terraform` |
| **Set PATH (permanent)** | `setx /M PATH "%PATH%;C:\terraform"` |
| **Check Terraform path** | `where terraform` |

---

✅ **AWS CLI and Terraform are now successfully installed and ready for use.**
```
