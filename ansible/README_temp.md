Ansible Automation: From Zero to Production-Ready

```markdown
# Ansible Automation Setup

This repository documents the complete setup for an Ansible control node and managed workers, 
including network configuration, SSH key setup, and Ansible installation.

## Table of Contents
1. [Network Configuration](#network-configuration)
2. [SSH Key Setup](#ssh-key-setup)
3. [Ansible Installation](#ansible-installation)
4. [Ansible Configuration](#ansible-configuration)
5. [Testing the Setup](#testing-the-setup)
6. [Example Playbook](#example-playbook)

## Network Configuration

Configure network settings using the `network.sh` script:

```bash
#!/bin/bash

# Read user input
read -p "Enter the current machine hostname: " hostname
read -p "Enter the current machine ip: " machine_ip

# Fix package issues and update system
sudo sed -i '/^deb file:\/cdrom/ s/^/#/' /etc/apt/sources.list
sudo dpkg --configure -a
sudo apt update
sudo apt install network-manager -y

# Configure NetworkManager
sudo bash -c 'cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[ifupdown]
managed=true
EOF'
sudo systemctl restart NetworkManager

# Configure Netplan
sudo bash -c 'cat > /etc/netplan/00-installer-config.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens33:
      dhcp4: no
      addresses: ['"$machine_ip/24"']
      gateway4: 192.168.2.2
      nameservers:
        addresses:
          - 8.8.8.8
EOF'
sudo netplan apply

# Add DNS servers and update hosts file
sudo bash -c 'cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF'
sudo bash -c 'cat >> /etc/hosts <<EOF
192.168.2.160 ansible
192.168.2.161 ansible-worker01
192.168.2.162 ansible-worker02
192.168.2.163 ansible-worker03
EOF'

# Set hostname
sudo hostnamectl set-hostname "$hostname"

# Verify IP configuration
ip a s ens33
```

Expected output:
```
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:43:83:c2 brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.2.160/24 brd 192.168.2.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe43:83c2/64 scope link dadfailed tentative
       valid_lft forever preferred_lft forever
```

## SSH Key Setup

1. Generate SSH keys on control node:
```bash
ssh-keygen
```

Expected output:
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/amer/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/amer/.ssh/id_rsa
Your public key has been saved in /home/amer/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:PN0TKu8S6thhYsGmqfacos5Jq/u6MJa8j0U6HMXLhZ0 amer@ansible
The key's randomart image is:
+---[RSA 3072]----+
|                 |
|  . o .          |
|   + E      .    |
|  o.o  . . o .   |
| . ++   S o o    |
|o =+ .  .+   .   |
|oOo.o o. ..      |
|==O..=....       |
|%%==..o  ..      |
+----[SHA256]-----+
```

2. Copy public key to worker nodes:
```bash
ssh-copy-id amer@ansible-worker01
```

Expected output:
```
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/amer/.ssh/id_rsa.pub"
The authenticity of host 'ansible-worker01 (192.168.2.161)' can't be established.
ED25519 key fingerprint is SHA256:LQzYNxcQYR+IOHQl/hFxI5XVAq7FoN93XLmZimBQ8U8.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
amer@ansible-worker01's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'amer@ansible-worker01'"
and check to make sure that only the key(s) you wanted were added.
```

3. Configure passwordless sudo on worker nodes:
```bash
echo "amer ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/amer
sudo chmod 440 /etc/sudoers.d/amer
```

4. Checking Public Key on worker nodes:
```bash
cat .ssh/authorized_keys
```

Expected output:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChS4itQOVgzkuJHKxcrubRubl8nBXTBwn4TLJCsEVIEf0N/BCvEh/aNVzIlpdKO5Kzts0qDAnY544vlzi1pR761iARazHnWC+e1RcqUFub1f8ZcajBhRxOg7JOnqSWQBoE4Mn6zvXruh3TfLXUzU2Uh7hKOTgp3t7cyZRGXL4nrbHFFjBDvrxj1hSHl6YRvvvauozAT4UUOMbEgelS5Y01gnH3vMJ3f2QmjqHtCwa22vMh9HL0mOoKNTKam8YqLN48ltUoSWC3J8gWPT92po/BmuQV1VBSQRpxi1rYO3+Pr1HXzsiF3YnXckaHgxSiXcM6onTs3pYMjxXYskghRU37+pgaGweU2nt3WQLcNdEYni4my3pLWNKywgUzyJgWM/XGxuMBC6W678Qp6uii4bD/UR7Cuk7vboNtCPmKJg6P/0U0vQOK8mWMlxZIGaOqycrVGGVCrttIx6IQu5sP+ep/VqO1ZvBRJ87mePh1XwbRHxWbtiCw5GU3SKuhIOpi9J0= amer@ansible
```

## Ansible Installation

Install Ansible on the control node:
```bash
sudo apt install python3 ansible -y
```

Verify installation:
```bash
ansible --version
```

Expected output:
```
ansible 2.10.8
  config file = None
  configured module search path = ['/home/amer/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.10.12 (main, Jul 29 2024, 16:56:48) [GCC 11.4.0]
```

## Ansible Configuration

1. Create Ansible directory:
```bash
sudo mkdir -p /etc/ansible
```

2. Configure `ansible.cfg`:
```bash
sudo sh -c 'cat > /etc/ansible/ansible.cfg <<EOF
[defaults]
inventory = /etc/ansible/servers.txt
host_key_checking = false
private_key_file = ~/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF'
```

3. Create inventory file:
```bash
sudo sh -c 'cat > /etc/ansible/servers.txt <<EOF
[workers]
ansible-worker01 ansible_host=192.168.2.161 ansible_user=amer ansible_become=true
EOF'
```

OR

```bash
sudo sh -c 'cat > /etc/ansible/servers.txt << EOF
[workers]
ansible-worker01
```

## Testing the Setup

1. Verify inventory:
```bash
ansible-inventory --graph
```

Expected output:
```
@all:
  |--@ungrouped:
  |--@workers:
  |  |--ansible-worker01
```

2. Test connectivity:
```bash
ansible workers -m ping -vvv
```

Expected output:
```
ansible-worker01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "invocation": {
        "module_args": {
            "data": "pong"
        }
    },
    "ping": "pong"
}
```

## Example Playbook

Create a test playbook to install nginx:

```yaml
---
- hosts: workers
  tasks:
    - name: Ensure nginx is installed
      apt:
        name: nginx
        state: present
```

Run the playbook:
```bash
ansible-playbook test.yml
```

Expected output:
```
PLAY [workers] **********************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************
ok: [ansible-worker01]

TASK [Ensure nginx is installed] ****************************************************************************************************
changed: [ansible-worker01]

PLAY RECAP **************************************************************************************************************************
ansible-worker01           : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Verify nginx installation on worker nodes:
```bash
sudo systemctl status nginx.service
```

Expected output:
```
amer@ansible-worker01:~$ sudo systemctl status nginx.service
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2025-05-20 00:35:39 UTC; 28s ago
       Docs: man:nginx(8)
    Process: 7180 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 7181 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 7298 (nginx)
      Tasks: 2 (limit: 4513)
     Memory: 3.2M
        CPU: 15ms
     CGroup: /system.slice/nginx.service
             ├─7298 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─7301 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

May 20 00:35:39 ansible-worker01 systemd[1]: Starting A high performance web server and a reverse proxy server...
May 20 00:35:39 ansible-worker01 systemd[1]: Started A high performance web server and a reverse proxy server.
```

## Troubleshooting

1. If SSH connections fail:
   - Verify network connectivity: `ping ansible-worker01`
   - Check SSH service: `systemctl status ssh`
   - Verify firewall rules

2. If sudo fails:
   - Check sudoers file permissions (should be 440)
   - Verify contents of `/etc/sudoers.d/amer`

3. For Ansible issues:
   - Run with verbose output: `-vvv`
   - Check Python interpreter discovery
```
