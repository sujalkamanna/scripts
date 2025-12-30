# 🛠️ scripts

<!-- License -->
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sujalkamanna/scripts/blob/main/LICENSE)

<!-- Repo Info -->
[![Repo Size](https://img.shields.io/github/repo-size/sujalkamanna/scripts?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sujalkamanna/scripts)

[![Open Issues](https://img.shields.io/github/issues/sujalkamanna/scripts?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sujalkamanna/scripts/issues)

[![Last Commit](https://img.shields.io/github/last-commit/sujalkamanna/scripts?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sujalkamanna/scripts/commits/main)




## Description

`scripts` is a DevOps automation repository that provides scripts, configuration files, and setup guides for managing infrastructure, CI/CD pipelines, containerization, and application deployment. The repository includes support for tools like **Ansible**, **Docker**, **Jenkins**, **Kubernetes**, **SonarQube**, **Tomcat**, and **Terraform** to help automate deployment and infrastructure management on Ubuntu systems.

---

Here is the **updated Repository Structure section** with the **new files added**, keeping everything else unchanged and concise.

---

## Repository Structure

| File / Folder              | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| `ansible_master_script.sh` | Script to set up the Ansible master node.                    |
| `ansible_slave_scripts.sh` | Script to configure Ansible slave nodes.                     |
| `ansible_configuration.md` | Documentation for configuring Ansible hosts and environment. |
| `docker.md`                | Documentation on Docker installation and usage.              |
| `docker.sh`                | Script for installing and managing Docker.                   |
| `docker-compose.sh`        | Script to install and configure Docker Compose.              |
| `docker-swarm.md`          | Documentation for setting up Docker Swarm.                   |
| `jenkins.sh`               | Script for installing and configuring Jenkins.               |
| `jenkins_pipeline/`        | Jenkins pipeline for building and deploying Java projects.   |
| `k8-README.md`             | Kubernetes cluster setup guide.                              |
| `k8-common-script`         | Common scripts for Kubernetes nodes.                         |
| `k8-master-script`         | Script for configuring Kubernetes master node.               |
| `k8-slave-script`          | Script for configuring Kubernetes worker nodes.              |
| `minikube.sh`              | Script to install and configure Minikube.                    |
| `self-hosted.md`           | Guide for self-hosted DevOps tools and runners.              |
| `sonarqube.sh`             | Script to install and configure SonarQube.                   |
| `terraform.md`             | Guide for installing Terraform and AWS CLI.                  |
| `tomcat.sh`                | Script to install and configure Tomcat 11.                   |
| `LICENSE`                  | MIT license file.                                            |
| `README.md`                | Main project documentation.                                  |
| `third_party_licenses.md`  | Third-party license acknowledgements.                        |

---

```text
📦 scripts
 ┣ 📜 ansible_configuration.md
 ┣ 📜 ansible_master_script.sh
 ┣ 📜 ansible_slave_scripts.sh
 ┣ 📜 docker-compose.sh
 ┣ 📜 docker-swarm.md
 ┣ 📜 docker.md
 ┣ 📜 docker.sh
 ┣ 📜 jenkins.sh
 ┣ 📂 jenkins_pipeline
 ┣ 📜 k8-common-script
 ┣ 📜 k8-master-script
 ┣ 📜 k8-README.md
 ┣ 📜 k8-slave-script
 ┣ 📜 minikube.sh
 ┣ 📜 self-hosted.md
 ┣ 📜 sonarqube.sh
 ┣ 📜 terraform.md
 ┣ 📜 tomcat.sh
 ┣ 📜 LICENSE
 ┣ 📜 README.md
 ┗ 📜 third_party_licenses.md
```

---

## Features

* **Automation:** Setup and configure Ansible, Kubernetes, Docker, Jenkins, Tomcat, and SonarQube automatically.
* **CI/CD Integration:** Jenkins pipeline to build and deploy Java applications.
* **Infrastructure as Code:** Terraform scripts and guides to automate cloud and local infrastructure setup.
* **Containerization:** Docker installation scripts and usage documentation for container‑based workflows.
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
````

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

## License

This repository and its original content (scripts, documentation, and configuration files) are licensed under the **MIT License**.

* Full text of the license: [https://github.com/sujalkamanna/scripts/blob/main/LICENSE](https://github.com/sujalkamanna/scripts/blob/main/LICENSE)
* SPDX License Identifier: `MIT`

You can also view the README file on GitHub here:
📄 [https://github.com/sujalkamanna/scripts/blob/main/README.md](https://github.com/sujalkamanna/scripts/blob/main/README.md)

---

## Third‑Party Licenses

This project references several external open‑source tools and installation guides. These references are *not owned* by this repository; their source code and documentation are licensed and maintained by their respective communities.

See the full list of third‑party components and their open‑source licenses here:
📄 [https://github.com/sujalkamanna/scripts/blob/main/third_party_licenses.md](https://github.com/sujalkamanna/scripts/blob/main/third_party_licenses.md)

Also see the `NOTICE` file for legal attributions and acknowledgements for third‑party open‑source tools.

---

## Contributing

Contributions are welcome! Please open issues or pull requests for improvements, bug fixes, or new automation scripts. By contributing, you agree that your contributions will be licensed under the same MIT terms.

---

## Notes

* The **LICENSE**, **NOTICE**, and **third_party_licenses.md** files help document open‑source compliance and clarify both your license and the licenses of external software referenced.
* Please review and comply with the licenses of third‑party tools you install or integrate.
---
