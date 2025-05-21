# Windows Server 2012 AWX Integration Documentation

## Successful Configuration Guide

This documentation outlines the verified steps to configure Windows Server 2012 for AWX integration, based on the successful commands executed in your environment.

---

### 1. PowerShell Remoting and WinRM Configuration

#### 1.1 Enable PowerShell Remoting
```powershell
Enable-PSRemoting -Force
```
**Purpose**: Configures the system to receive PowerShell remote commands.

**Outcome**: Successfully enabled WS-Management protocol and created necessary listeners.

#### 1.2 Quick WinRM Configuration
```powershell
winrm quickconfig -q
```
**Purpose**: Sets up WinRM with default settings (quiet mode).

**Outcome**: Created HTTP listener on port 5985 and enabled firewall exception.

#### 1.3 Configure WinRM Security Settings
```powershell
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
```
**Purpose**: 
- Allows unencrypted traffic (required for basic authentication)
- Enables basic authentication for WinRM

**Outcome**: Successfully configured as verified by subsequent checks.

#### 1.4 Firewall Configuration
```powershell
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
```
**Purpose**: Explicitly opens port 5985 in Windows Firewall.

**Outcome**: Rule added successfully to allow incoming WinRM connections.

#### 1.5 Service Configuration
```powershell
Set-Service -Name WinRM -StartupType Automatic
Restart-Service WinRM
```
**Purpose**: 
- Ensures WinRM starts automatically with system
- Applies configuration changes

**Outcome**: Service configured and restarted successfully.

#### 1.6 Verification
```powershell
winrm enumerate winrm/config/listener
```
**Expected Output**: Should show HTTP listener active on port 5985.

---

### 2. AWX User Creation (Windows Server 2012 Specific)

#### 2.1 Create Local User Account
```powershell
net user AWXUser "YourSecurePassword123!" /add /comment:"AWX Automation Account"
```
**Purpose**: Creates the automation user account.

**Note**: On Windows Server 2012, this is the preferred method over `New-LocalUser`.

**Outcome**: User created successfully (confirmed by successful command completion).

#### 2.2 Add User to Administrators Group
```powershell
net localgroup Administrators AWXUser /add
```
**Purpose**: Grants administrative privileges to the AWX user.

**Outcome**: User successfully added to Administrators group.

#### 2.3 Set Password to Never Expire
```powershell
wmic useraccount where "name='AWXUser'" set PasswordExpires=FALSE
```
**Purpose**: Ensures the automation account doesn't require periodic password changes.

**Outcome**: Successfully configured (after correcting syntax from earlier attempts).

---

### 3. Final Verification Steps

#### 3.1 Verify User Account
```powershell
net user AWXUser
```
**Expected Output**: Shows user details including "Password expires: Never".

#### 3.2 Verify Group Membership
```powershell
net localgroup Administrators
```
**Expected Output**: Should list "AWXUser" among members.

#### 3.3 Verify WinRM Configuration
```powershell
winrm get winrm/config/service
winrm get winrm/config/service/auth
```
**Expected Output**: 
- `AllowUnencrypted = true`
- `Basic = true`

---

amer@amer:~$ kubectl exec -it my-awx-69d6fb48b9-52l7b -n awx -c task -- ls -la /var/lib/awx/projects
total 16
drwxr-xr-x 3 awx  root 4096 May 17 22:08 .
drwxrwxr-x 1 root root 4096 May 17 18:49 ..
-rwxr-xr-x 1 awx  root    0 May 17 18:23 _6__win_system_info.lock
drwxr-xr-x 3 awx  root 4096 May 17 18:23 .__awx_cache
amer@amer:~$
amer@amer:~$ kubectl exec -it my-awx-69d6fb48b9-52l7b -n awx -c task -- mkdir -p /var/lib/awx/projects/_6__win_system_info/
amer@amer:~$ kubectl exec -it my-awx-69d6fb48b9-52l7b -n awx -c task -- ls -la /var/lib/awx/projects/
total 20
drwxr-xr-x 4 awx  root 4096 May 18 18:21 .
drwxrwxr-x 1 root root 4096 May 17 18:49 ..
drwxr-xr-x 2 awx  root 4096 May 18 18:21 _6__win_system_info
-rwxr-xr-x 1 awx  root    0 May 17 18:23 _6__win_system_info.lock
drwxr-xr-x 3 awx  root 4096 May 17 18:23 .__awx_cache
amer@amer:~$ kubectl exec -it my-awx-69d6fb48b9-52l7b -n awx -c task -- ls -la /var/lib/awx/projects/_6__win_system_info/
total 8
drwxr-xr-x 2 awx root 4096 May 18 18:21 .
drwxr-xr-x 4 awx root 4096 May 18 18:21 ..
amer@amer:~$ kubectl cp win_system_info.yml my-awx-69d6fb48b9-52l7b:/var/lib/awx/projects/_6__win_system_info/ -n awx -c task
amer@amer:~$ kubectl exec -it my-awx-69d6fb48b9-52l7b -n awx -c task -- ls -la /var/lib/awx/projects/_6__win_system_info/
total 12
drwxr-xr-x 2 awx root 4096 May 18 19:02 .
drwxr-xr-x 4 awx root 4096 May 18 18:21 ..
-rw-r--r-- 1 awx root  152 May 18 19:02 win_system_info.yml
amer@amer:~$ kubectl exec -it my-awx-5fb45b8f74-mbms7 -n awx -c task -- \
ls -la /var/lib/awx/projects/_7__windows_server_information/
total 108
drwxr-xr-x 23 awx root 4096 May 18 22:35  .
drwxr-xr-x  6 awx root 4096 May 18 22:35  ..
drwxr-xr-x  4 awx root 4096 May 18 22:35  ansible
drwxr-xr-x  3 awx root 4096 May 18 22:35  ArgoCD
drwxr-xr-x  2 awx root 4096 May 18 22:35  Articles
drwxr-xr-x  4 awx root 4096 May 18 22:35  Bash-Script
-rw-r--r--  1 awx root 4945 May 18 22:35  build-test-deploy.txt
drwxr-xr-x  3 awx root 4096 May 18 22:35  DataBase
drwxr-xr-x  2 awx root 4096 May 18 22:35 'DevOps Implementation for Middleware and Database Configuration'
drwxr-xr-x  4 awx root 4096 May 18 22:35  docker
drwxr-xr-x  8 awx root 4096 May 18 22:35  .git
drwxr-xr-x  3 awx root 4096 May 18 22:35  Git
drwxr-xr-x  2 awx root 4096 May 18 22:35  GitLab
drwxr-xr-x  3 awx root 4096 May 18 22:35  Helm
drwxr-xr-x  3 awx root 4096 May 18 22:35  jenkins
drwxr-xr-x  2 awx root 4096 May 18 22:35  K9s
drwxr-xr-x  4 awx root 4096 May 18 22:35 'KinD + K3d'
drwxr-xr-x  4 awx root 4096 May 18 22:35  kubernetes
drwxr-xr-x  3 awx root 4096 May 18 22:35  Linux
drwxr-xr-x  4 awx root 4096 May 18 22:35  Monitoring-Tools
-rw-r--r--  1 awx root  249 May 18 22:35 'password-encryption using base64.txt'
drwxr-xr-x  2 awx root 4096 May 18 22:35  Proxy
drwxr-xr-x  4 awx root 4096 May 18 22:35  terraform
drwxr-xr-x  3 awx root 4096 May 18 22:35  vagrant
drwxr-xr-x  3 awx root 4096 May 18 22:35  windows
-rw-r--r--  1 awx root   66 May 18 22:35 'you ip a.txt'

amer@amer:~$ kubectl exec -it my-awx-5fb45b8f74-mbms7 -n awx -c task -- \
ansible-playbook --syntax-check /var/lib/awx/projects/_7__windows_server_information/win_facts.yml
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does
not match 'all'

playbook: /var/lib/awx/projects/_7__windows_server_information/win_facts.yml

bash-4.4$ ansible win-server-2012 -m win_ping -i /var/lib/awx/projects/_7__windows_server_information/test_inventory.yml
win-server-2012 | FAILED! => {
    "msg": "winrm or requests is not installed: No module named 'winrm'"
}
bash-4.4$ cat /var/lib/awx/projects/_7__windows_server_information/test_inventory.yml                        all:
  hosts:
    win-server-2012:
      ansible_host: 192.168.1.120
      ansible_user: AMXUser
      ansible_password: YourSecurePassword123!
      ansible_connection: winrm
      ansible_winrm_transport: basic
      ansible_winrm_server_cert_validation: ignore
      ansible_port: 5985bash-4.4$
---
### **Step 1: Add Windows Host to AWX Inventory**
#### **1.1 Log in to AWX Web UI**
- Access `http://<AWX_SERVER_IP>:8081`  
- Login with `admin` and your password  

#### **1.2 Create Inventory**
1. Navigate to:  
   **Resources → Inventories → Add → Inventory**  
2. Fill in:  
   - **Name**: `Windows Servers`  
   - **Organization**: `Default`  
3. Click **Save**  

#### **1.3 Add Windows Host**
1. In the inventory, click **Hosts → Add**  
2. Configure:  
   - **Host Name**: `win-server-2012`  
   - **Variables** (YAML):  
     ```yaml
     ansible_host: 192.168.2.120
	 ansible_user: AMXUser
	 ansible_password: YourSecurePassword123!
	 ansible_connection: winrm
	 ansible_winrm_transport: basic
	 ansible_winrm_server_cert_validation: ignore
	 ansible_port: 5985
     ansible_winrm_server_cert_validation: ignore
     ```
3. Click **Save**  

---

### **Step 2: Create & Run a Windows Job**
#### **2.1 Create Playbook**
1. Navigate to:  
   **Resources → Projects → Default → Add File**  
2. Name: `win_basic_info.yml`  
3. Content:  
   ```yaml
   ---
   - name: Get Windows System Info
     hosts: all
     gather_facts: no

     tasks:
       - name: Collect system info
         ansible.windows.win_system_info:
         register: win_info

       - name: Display info
         debug:
           var: win_info
   ```
4. Click **Save**  

#### **2.2 Create Job Template**
1. Go to:  
   **Resources → Templates → Add → Job Template**  
2. Configure:  
   - **Name**: `Windows System Info`  
   - **Inventory**: `Windows Servers`  
   - **Project**: `Default`  
   - **Playbook**: `win_basic_info.yml`  
   - **Credentials**: Select your Windows credential  
   - **Options**:  
     - ☑ **Enable Privilege Escalation**  
     - ☑ **Enable Fact Storage**  
3. Click **Save**  

#### **2.3 Execute the Job**
1. In **Templates**, click **Launch** on `Windows System Info`.  
2. Monitor real-time output in the **Jobs** view.  

**Expected Output**:  
```json
{
  "win_info": {
    "hostname": "WIN-2012",
    "os_version": "6.3.9600",
    "uptime": "1 day, 3 hours"
  }
}
```

---

### **Step 3: Troubleshooting**
#### **3.1 Verify WinRM Connectivity**
```bash
# Test WinRM from AWX server
ansible win-server-2012 -i inventory.ini -m ansible.windows.win_ping -vvv
```
**If fails**:  
- Check Windows Server:  
  ```powershell
  Test-NetConnection -ComputerName 192.168.2.129 -Port 5985
  ```
- Ensure WinRM is running:  
  ```powershell
  Get-Service WinRM
  ```
---
- name: Gather Windows Facts
  hosts: all
  gather_facts: yes

  tasks:
    - name: Display OS version
      debug:
        var: ansible_os_version