# 🔧 Semaphore Ansible CI/CD Tool - Docker Compose Installation

![Semaphore Logo](https://semaphoreci.com/blog/assets/images/semaphore-logo-3d9cffd3.png)

> 🚀 *A modern, lightweight CI/CD tool for Ansible automation.*

## 📌 Project Summary

This project provides a **Docker Compose-based deployment** of [Semaphore](https://github.com/ansible-semaphore/semaphore), a powerful open-source CI/CD tool designed specifically for managing Ansible workflows. It allows developers and DevOps teams to easily automate deployments using playbooks, inventory management, secrets handling, and real-time logging.

With this setup, you can:
- Quickly deploy Semaphore on any Linux server.
- Use persistent volumes for configuration and data retention.
- Integrate with Ansible for automated task execution.
- Securely manage users and environments.

---

## 🏗️ Architecture Overview

![Architecture Diagram Placeholder](docs/architecture-diagram.png)

> _Note: You can replace the above image with your actual architecture diagram._

The system consists of:
- A **single containerized instance** of Semaphore running on port 3000.
- Three **persistent volumes** for storing configurations, application data, and temporary files like cloned repositories.
- Environment variables for initial admin setup and database backend (using BoltDB).

---

## 🛠️ Prerequisites

Before starting, ensure the following are installed or available:

| Tool | Version | Description |
|------|---------|-------------|
| 💻 OS | Ubuntu 20.04+ | Or any Linux distribution |
| 🐳 Docker Engine | Latest | Container runtime |
| 🐳 Docker Compose | v2+ | For orchestrating containers |
| 🧪 Ansible | Optional | For playbook integration |

---

## 📦 Installation Steps

### 1. Install Docker Compose v2

```bash
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
```

Verify installation:
```bash
docker compose version
```

### 2. Create Docker Compose File

Create `docker-compose.yml` with the following content:

```yaml
version: '3'
services:
  semaphore:
    image: public.ecr.aws/semaphore/pro/server:v2.14.8
    container_name: semaphore
    ports:
      - "3000:3000"
    environment:
      - SEMAPHORE_DB_DIALECT=bolt
      - SEMAPHORE_ADMIN=admin
      - SEMAPHORE_ADMIN_PASSWORD=changeme
      - SEMAPHORE_ADMIN_NAME=Admin
      - SEMAPHORE_ADMIN_EMAIL=admin@localhost
    volumes:
      - semaphore_data:/var/lib/semaphore
      - semaphore_config:/etc/semaphore
      - semaphore_tmp:/tmp/semaphore
    restart: unless-stopped

volumes:
  semaphore_data:
  semaphore_config:
  semaphore_tmp:
```

### 3. Start the Application

```bash
docker compose up -d
```

### 4. Verify Running Containers

```bash
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                                         COMMAND                  CREATED        STATUS        PORTS                                       NAMES
8713c8afd0a1   public.ecr.aws/semaphore/pro/server:v2.14.8   "/sbin/tini -- /usr/…"   5 mins ago     Up 5 mins     0.0.0.0:3000->3000/tcp                      semaphore
```

---

## 🌐 Accessing Semaphore UI

1. Open browser: `http://<your-server-ip>:3000`
2. Log in with:
   - **Username:** `admin`
   - **Password:** `changeme`

> ⚠️ **Important**: Change the default password after first login.

---

## 🧰 Configuration

### Volumes

| Volume | Path Inside Container | Purpose |
|--------|-----------------------|---------|
| `semaphore_data` | `/var/lib/semaphore` | Persistent data (projects, tasks) |
| `semaphore_config` | `/etc/semaphore` | Config files, settings |
| `semaphore_tmp` | `/tmp/semaphore` | Temp files (cloned repos, logs) |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SEMAPHORE_DB_DIALECT` | Database engine | `bolt` |
| `SEMAPHORE_ADMIN` | Admin username | `admin` |
| `SEMAPHORE_ADMIN_PASSWORD` | Admin password | `changeme` |
| `SEMAPHORE_ADMIN_NAME` | Display name | `Admin` |
| `SEMAPHORE_ADMIN_EMAIL` | Admin email | `admin@localhost` |

---

## 🔄 Maintenance Commands

| Task | Command |
|------|---------|
| Stop app | `docker compose down` |
| Start app | `docker compose up -d` |
| Update image | `docker compose pull && docker compose up -d` |
| View logs | `docker compose logs -f` |

### Backup Data

```bash
docker compose stop
sudo tar czvf semaphore_backup_$(date +%Y%m%d).tar.gz $(docker volume inspect semaphore_data semaphore_config semaphore_tmp | jq -r '.[].Mountpoint')
docker compose start
```

---

## 🔒 Security Recommendations

✅ Always do the following post-installation:

- ✅ Change the default admin password immediately  
- ✅ Set up HTTPS via Nginx/Apache reverse proxy  
- ✅ Restrict access to port 3000 using a firewall  
- ✅ Regularly update Semaphore to the latest version  