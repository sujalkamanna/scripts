# Connect One EC2 Instance to Another Using Remote SSH

This guide explains how to launch two AWS EC2 instances and configure SSH key-based authentication so that one instance can connect to the other remotely.

## 1. Launch Two EC2 Instances

Launch **two EC2 instances** in AWS.

* **Host Machine** — the machine from which you initiate the SSH connection.
* **Server 1** — the target EC2 instance that the Host Machine will connect to.

Example:

```text
Host Machine
     |
     | SSH
     v
Server 1
```

## 2. Set the Hostname

Set a meaningful hostname on both machines.

For example:

```text
Host Machine
Server1
```

You can verify the hostname with:

```bash
hostname
```

## 3. Generate SSH Keys on the Host Machine

SSH keys are stored in:

```bash
/root/.ssh
```

Generate a new SSH key pair using:

```bash
ssh-keygen
```

Press **Enter** for the default options:

```text
Enter
Enter
Enter
```

This creates two keys:

* `id_rsa` — private key
* `id_rsa.pub` — public key

Depending on the SSH configuration, you may instead get:

* `id_ed25519`
* `id_ed25519.pub`

> **Important:** Never share your private key.

## 4. Start the SSH Agent

Run the following command on the Host Machine:

```bash
eval $(ssh-agent -s)
```

The SSH agent will start and return a process ID.

Example:

```text
Agent pid 11464
```

## 5. Create the PEM File

Create a `.pem` file using the same key name that was used when creating the EC2 instances.

For example:

```bash
vi your_pem_keyname.pem
```

Paste the contents of your AWS `.pem` private key into the file and save it.

## 6. Set Permissions on the PEM File

SSH requires appropriate permissions for private key files.

Run:

```bash
chmod 400 your_pem_keyname.pem
```

## 7. Add the PEM Key to the SSH Agent

Add the key to the SSH agent:

```bash
ssh-add your_pem_keyname.pem
```

You should see output similar to:

```text
Identity added: your_pem_keyname.pem (your_pem_keyname.pem)
```

## 8. Check the SSH Directory

Navigate to the SSH directory:

```bash
cd /root/.ssh
```

List the available keys:

```bash
ls
```

You should see something similar to:

```text
id_rsa
id_rsa.pub
```

or:

```text
id_ed25519
id_ed25519.pub
```

The `.pub` file is the **public key** that will be copied to the target server.

## 9. Copy the Public Key to Server 1

Use `ssh-copy-id` to copy the public key to Server 1.

General syntax:

```bash
ssh-copy-id -i id_rsa.pub ubuntu@<PRIVATE_IP_OF_SERVER>
```

For example:

```bash
ssh-copy-id -i id_rsa.pub ubuntu@172.31.33.136
```

Here:

* `id_rsa.pub` = public SSH key
* `ubuntu` = username on the EC2 instance
* `172.31.33.136` = private IP address of Server 1

You can find the server's IP address using:

```bash
hostname -i
```

### Expected Output

If the key is successfully copied, you should see something similar to:

```text
Number of key(s) added: 1

Now try logging into the machine, with:

"ssh 'ubuntu@172.31.33.136'"

and check to make sure that only the key(s) you wanted were added.
```

## 10. Connect to Server 1

Now connect from the Host Machine to Server 1:

```bash
ssh ubuntu@172.31.33.136
```

If the SSH key configuration is correct, you should be logged into Server 1 without needing to enter the PEM key each time.

Verify that you are on Server 1:

```bash
hostname
```

## 11. Return to the Host Machine

To disconnect from Server 1 and return to the Host Machine, use:

```bash
exit
```

Alternatively, press:

```text
Ctrl + D
```

## Complete Flow

The overall process is:

```text
1. Launch two EC2 instances
        |
        v
2. Set hostnames
        |
        v
3. Generate SSH key pair on Host Machine
        |
        v
4. Start ssh-agent
        |
        v
5. Create and secure the PEM file
        |
        v
6. Add PEM key using ssh-add
        |
        v
7. Locate id_rsa.pub
        |
        v
8. Copy public key to Server 1
        |
        v
9. SSH into Server 1
        |
        v
10. Use exit / Ctrl+D to return
```

## Important SSH Files

| File                   | Purpose                   |
| ---------------------- | ------------------------- |
| `id_rsa`               | Private SSH key           |
| `id_rsa.pub`           | Public SSH key            |
| `your_pem_keyname.pem` | AWS EC2 private key       |
| `/root/.ssh`           | Default SSH key directory |

> **Security Note:** Keep private keys such as `id_rsa` and `.pem` files secure. Never share or commit them to Git repositories.
