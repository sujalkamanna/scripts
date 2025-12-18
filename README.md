---

# scripts

## Description

`scripts` is a DevOps automation repository that provides scripts, configuration files, and setup guides for managing infrastructure, CI/CD pipelines, containerization, and application deployment. The repository includes support for tools like **Ansible**, **Docker**, **Jenkins**, **Kubernetes**, **SonarQube**, **Tomcat**, and **Terraform** to help automate deployment and infrastructure management on Ubuntu systems.

---

## Repository Structure

| File / Folder              | Description                                                                              |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| `ansible_master_script.sh` | Script to set up the Ansible master node with instructions.                              |
| `ansible_slave_scripts.sh` | Scripts to configure Ansible slave nodes for automation tasks.                           |
| `ansible_configuration.md` | Documentation for configuring Ansible hosts and environment.                             |
| `docker.md`                | Documentation on Docker installation and usage.                                          |
| `docker.sh`                | Script for installing and managing Docker with improved comments and usage instructions. |
| `jenkins.sh`               | Script for installing and configuring Jenkins.                                           |
| `jenkins_pipeline/`        | Contains a Jenkins pipeline for building and deploying Java projects.                    |
| `k8-README.md`             | Guide for setting up a Kubernetes cluster on Ubuntu 24.04.                               |
| `k8-common-script`         | Common scripts used across Kubernetes master and slave nodes.                            |
| `k8-master-script`         | Script for configuring Kubernetes master node.                                           |
| `k8-slave-script`          | Script for configuring Kubernetes worker nodes.                                          |
| `sonarqube.sh`             | Script to install and configure SonarQube.                                               |
| `terraform.md`             | Guide for installing Terraform and AWS CLI for infrastructure automation.                |
| `tomcat.sh`                | Script to install and configure Tomcat 11.                                               |

---

## Features

* **Automation:** Setup and configure Ansible, Kubernetes, Docker, Jenkins, Tomcat, and SonarQube automatically.
* **CI/CD Integration:** Jenkins pipeline to build and deploy Java applications.
* **Infrastructure as Code:** Terraform scripts and guides to automate cloud and local infrastructure setup.
* **Containerization:** Docker installation scripts and usage documentation for container-based workflows.
* **Cluster Management:** Kubernetes setup scripts for master and worker nodes on Ubuntu.

---

## Getting Started

### Prerequisites

* Ubuntu 24.04 (or compatible Linux distribution)
* Sudo privileges on all nodes
* Internet access for downloading required packages

### Example Usage

1. **Setup Ansible Master Node**

```bash
bash ansible_master_script.sh
```

2. **Configure Ansible Slave Nodes**

```bash
bash ansible_slave_scripts.sh
```

3. **Install Docker**

```bash
bash docker.sh
```

4. **Install Jenkins and Run Pipeline**

```bash
bash jenkins.sh
```

Navigate to the `jenkins_pipeline/` folder for the pipeline setup.

5. **Set up Kubernetes Cluster**

* Run `k8-master-script` on master node
* Run `k8-slave-script` on worker nodes

6. **Install SonarQube**

```bash
bash sonarqube.sh
```

7. **Install Tomcat**

```bash
bash tomcat.sh
```

---

## Contributing

Contributions are welcome! Please open issues or pull requests for improvements, bug fixes, or new automation scripts.

---

## License

Specify your license here (e.g., MIT, Apache 2.0).

---
