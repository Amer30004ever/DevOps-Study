# 🛠️ Windows Server 2012 Configuration for AWX Integration

![Architecture Diagram](architecture.png)

## 🔍 Project Summary
This project demonstrates how to configure a **Windows Server 2012** machine for seamless integration with **AWX (Ansible Tower)**. It outlines the necessary steps to enable PowerShell Remoting, configure WinRM, and create a dedicated user account for automation purposes. Additionally, it includes Ansible playbooks for managing both Linux and Windows hosts using AWX.

The configuration ensures secure remote access via WinRM, compatibility with older versions of Windows, and provides best practices for automation workflows.

---

## 📋 Key Configuration Steps

### 1. Enable PowerShell Remoting and Configure WinRM
```powershell
# Enable PowerShell Remoting
Enable-PSRemoting -Force

# Configure WinRM basic settings
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Open firewall port
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

# Set WinRM service to auto-start and restart
Set-Service -Name WinRM -StartupType Automatic
Restart-Service WinRM
```

**Verification**:
```powershell
winrm enumerate winrm/config/listener
```
(Should show HTTP listener on port 5985)

### 2. Create AWX User Account
For Windows Server 2012, we must use the legacy `net user` command instead of PowerShell's `New-LocalUser`:
```cmd
net user AWXUser "YourSecurePassword123!" /add /comment:"AWX Automation Account"
net localgroup Administrators AWXUser /add
```

### 3. Configure Password Never Expires
```powershell
wmic useraccount where "name='AWXUser'" set PasswordExpires=FALSE
```

---

## ⚠️ Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| `New-LocalUser` not available | Use `net user` command instead |
| Incorrect group name | Ensure you use "Administrators" (plural) not "Administrator" |
| WinRM configuration syntax errors | Use exact syntax: `winrm set winrm/config/service/auth '@{Basic="true"}'` |
| Password expiration setting | Note the correct parameter is `PasswordExpires` (not "PasswordExpress") |

---

## ✅ Final Verification

1. Verify user creation:
   ```cmd
   net user AWXUser
   ```

2. Check group membership:
   ```cmd
   net localgroup Administrators
   ```

3. Confirm WinRM settings:
   ```powershell
   winrm get winrm/config/service
   winrm get winrm/config/service/auth
   ```

---

## 🐧 Ansible VM Setup

```bash
sudo apt update
sudo apt install python3-pip
sudo pip3 install pywinrm
```

---

## 📄 Ansible Configuration

```ini
[defaults]
inventory = /etc/ansible/servers.txt
host_key_checking = false
private_key_file = ~/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

---

## 🖥️ Inventory File

```ini
# Linux hosts
[linux]
ansible-worker01

[linux:vars]
ansible_connection=ssh
ansible_ssh_private_key_file=~/.ssh/id_rsa

# Windows hosts - SINGLE DEFINITION ONLY
[windows]
192.168.1.128

[windows:vars]
ansible_user=Administrator
ansible_password=Amer@1234
ansible_connection=winrm
ansible_winrm_transport=ntlm
ansible_winrm_port=5985
ansible_winrm_scheme=http
ansible_winrm_server_cert_validation=ignore
ansible_become=no
```

---

## 🧪 Playbooks

### Configure Windows Server 2012

```yaml
---
- name: Configure Windows Server 2012
  hosts: windows
  gather_facts: yes
  tasks:
    - name: Ensure IIS is installed
      win_feature:
        name: Web-Server
        state: present
        include_management_tools: yes

    - name: Create sample directory
      win_file:
        path: C:\Temp\AnsibleDemo
        state: directory

    - name: Copy test file to Windows
      win_copy:
        src: /etc/ansible/testfile.txt
        dest: C:\Temp\AnsibleDemo\testfile.txt

    - name: Display system information
      win_command: systeminfo
      register: systeminfo

    - name: Show system information
      debug:
        var: systeminfo.stdout_lines
```

### Revert Changes

```yaml
---
- name: Revert Windows Server 2012 Configuration
  hosts: windows
  gather_facts: yes
  tasks:
    # Remove IIS using win_feature (will do nothing if not installed)
    - name: Ensure IIS is removed
      win_feature:
        name: Web-Server
        state: absent
      when: ansible_os_family == 'Windows'
      ignore_errors: yes

    # Remove the sample directory and its contents
    - name: Remove sample directory structure
      win_file:
        path: C:\Temp\AnsibleDemo
        state: absent
      when: ansible_os_family == 'Windows'

    # Verify removal by checking directory only
    - name: Verify directory removal
      win_shell: |
        Write-Output "Directory Contents of C:\\Temp:"
        if (Test-Path C:\\Temp) { Get-ChildItem C:\\Temp -Recurse }
        else { Write-Output "C:\\Temp\\AnsibleDemo directory does not exist" }
      register: dir_verification

    - name: Display verification results
      debug:
        var: dir_verification.stdout_lines
```

---

## 📈 Execution Output Example

```bash
amer@ansible:/etc/ansible$ ls
ansible.cfg  revert_changes.yml  servers.txt  testfile.txt  windows_playbook.yml

amer@ansible:/etc/ansible$ ansible-playbook windows_playbook.yml
PLAY [Configure Windows Server 2012] *************************************************************************
TASK [Gathering Facts] ***************************************************************************************
ok: [192.168.1.128]
TASK [Ensure IIS is installed] *******************************************************************************
changed: [192.168.1.128]
TASK [Create sample directory] *******************************************************************************
changed: [192.168.1.128]
TASK [Copy test file to Windows] *****************************************************************************
changed: [192.168.1.128]
TASK [Display system information] ****************************************************************************
changed: [192.168.1.128]
TASK [Show system information] *******************************************************************************
ok: [192.168.1.128] => {
    "systeminfo.stdout_lines": [
        "",
        "Host Name:                 WIN-A642RVA4MVJ",
        "OS Name:                   Microsoft Windows Server 2012 R2 Datacenter Evaluation",
        "OS Version:                6.3.9600 N/A Build 9600",
        "OS Manufacturer:           Microsoft Corporation",
        "OS Configuration:          Standalone Server",
        "OS Build Type:             Multiprocessor Free",
        "Registered Owner:          Windows User",
        "Registered Organization:   ",
        "Product ID:                00252-90000-00000-AA632",
        "Original Install Date:     5/11/2025, 8:44:34 PM",
        "System Boot Time:          5/19/2025, 1:20:58 AM",
        "System Manufacturer:       VMware, Inc.",
        "System Model:              VMware Virtual Platform",
        "System Type:               x64-based PC",
        "Processor(s):              1 Processor(s) Installed.",
        "                           [01]: Intel64 Family 6 Model 165 Stepping 2 GenuineIntel ~2400 Mhz",
        "BIOS Version:              Phoenix Technologies LTD 6.00, 11/12/2020",
        "Windows Directory:         C:\\Windows",
        "System Directory:          C:\\Windows\\system32",
        "Boot Device:               \\Device\\HarddiskVolume1",
        "System Locale:             en-us;English (United States)",
        "Input Locale:              en-us;English (United States)",
        "Time Zone:                 (UTC-08:00) Pacific Time (US & Canada)",
        "Total Physical Memory:     16,383 MB",
        "Available Physical Memory: 15,385 MB",
        "Virtual Memory: Max Size:  18,303 MB",
        "Virtual Memory: Available: 17,346 MB",
        "Virtual Memory: In Use:    957 MB",
        "Page File Location(s):     C:\\pagefile.sys",
        "Domain:                    WORKGROUP",
        "Logon Server:              \\\\WIN-A642RVA4MVJ",
        "Hotfix(s):                 6 Hotfix(s) Installed.",
        "                           [01]: KB2919355",
        "                           [02]: KB2919442",
        "                           [03]: KB2937220",
        "                           [04]: KB2938772",
        "                           [05]: KB2939471",
        "                           [06]: KB2949621",
        "Network Card(s):           1 NIC(s) Installed.",
        "                           [01]: Intel(R) 82574L Gigabit Network Connection",
        "                                 Connection Name: Ethernet0",
        "                                 DHCP Enabled:    Yes",
        "                                 DHCP Server:     192.168.1.254",
        "                                 IP address(es)",
        "                                 [01]: 192.168.1.128",
        "                                 [02]: fe80::94c6:e882:9f24:3df4",
        "Hyper-V Requirements:      A hypervisor has been detected. Features required for Hyper-V will not be displayed."
    ]
}
PLAY RECAP ***************************************************************************************************
192.168.1.128              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

---

## 📦 Verbose Output Example

> *(See full output in original documentation)*

---

## 🧾 License

MIT License  
Copyright © 2025 Your Name  
Permission is hereby granted...  

--- 

> 💡 Tip: Replace `architecture.png` with your actual architecture diagram image file.