# Installing And Setting Up Docker Swarm

## 1. Install Docker

📍 **Run on: ALL nodes (Manager + Worker/Slave)**

```bash
sudo apt update
curl -fsSL https://get.docker.com | sudo sh
sudo systemctl enable docker
sudo systemctl start docker
```

---

## 2. Initialize Swarm

📍 **Run on: MANAGER (Master) node only**

```bash
docker swarm init
```
Or

```bash
docker swarm init --advertise-addr <MANAGER_PRIVATE_IP>
```

➡️ This command will output a **join token** for workers.

---

## 3. Join Workers

📍 **Run on: WORKER / SLAVE nodes only**

Use the join command shown on the manager, for example:

```bash
docker swarm join --token S...xyz <PRIVATE-IP>
```

---

## 4. Verify Swarm

📍 **Run on: MANAGER node only**

```bash
docker node ls
```

You should see:

* Manager → `Leader`
* Workers → `Ready`

---

## 5. Open Required Ports

📍 **Apply on: ALL nodes (security group / firewall)**

Allow traffic **between nodes**:

* `2377` TCP (Swarm management)
* `7946` TCP/UDP (Node communication)
* `4789` UDP (Overlay network)

---

## 6. Test Swarm

📍 **Run on: MANAGER node only**

```bash
docker service create --name web -p 80:80 --replicas 2 nginx
```

---

## 7. Access Service

📍 **From: Any browser**

```
http://<ANY_NODE_IP>
```

---

### ✅ Done

Docker Swarm is running successfully 🚀
