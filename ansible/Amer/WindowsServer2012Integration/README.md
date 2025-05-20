# Windows Server 2012 Configuration for AWX Integration

## Summary of Configuration Steps
This document outlines the steps to properly configure a Windows Server 2012 machine for integration with AWX (Ansible Tower). The process focuses on enabling PowerShell Remoting, configuring WinRM, and creating a dedicated user account.

## Key Configuration Steps

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

## Common Issues and Solutions
1. **`New-LocalUser` not available**:  
   - Windows Server 2012 doesn't support this cmdlet (introduced in Server 2016)  
   - Solution: Use `net user` command instead

2. **Incorrect group name**:  
   - Ensure you use "Administrators" (plural) not "Administrator"

3. **WinRM configuration syntax errors**:  
   - Use exact syntax: `winrm set winrm/config/service/auth '@{Basic="true"}'`

4. **Password expiration setting**:  
   - Note the correct parameter is `PasswordExpires` (not "PasswordExpress")

## Final Verification
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

This configuration provides secure remote management capabilities while maintaining compatibility with Windows Server 2012's older feature set.

# Ansible VM Setup
```bash
sudo apt update
sudo apt install python3-pip
sudo pip3 install pywinrm
```

## Ansible Configuration
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

## Inventory File
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

## Playbooks

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
        Write-Output "Directory Contents of C:\Temp:"
        if (Test-Path C:\Temp) { Get-ChildItem C:\Temp -Recurse }
        else { Write-Output "C:\Temp\AnsibleDemo directory does not exist" }
      register: dir_verification

    - name: Display verification results
      debug:
        var: dir_verification.stdout_lines
```

## Execution Output Example
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

## Verbose Output Example
```bash
amer@ansible:/etc/ansible$ ansible-playbook revert_changes.yml -vvv
ansible-playbook 2.10.8
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/amer/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.10.12 (main, Feb  4 2025, 14:57:36) [GCC 11.4.0]
Using /etc/ansible/ansible.cfg as config file
host_list declined parsing /etc/ansible/servers.txt as it did not pass its verify_file() method
script declined parsing /etc/ansible/servers.txt as it did not pass its verify_file() method
auto declined parsing /etc/ansible/servers.txt as it did not pass its verify_file() method
yaml declined parsing /etc/ansible/servers.txt as it did not pass its verify_file() method
Parsed /etc/ansible/servers.txt inventory source with ini plugin
redirecting (type: modules) ansible.builtin.win_feature to ansible.windows.win_feature
redirecting (type: modules) ansible.builtin.win_file to ansible.windows.win_file
redirecting (type: modules) ansible.builtin.win_shell to ansible.windows.win_shell
Skipping callback 'default', as we already have a stdout callback.
Skipping callback 'minimal', as we already have a stdout callback.
Skipping callback 'oneline', as we already have a stdout callback.
PLAYBOOK: revert_changes.yml *********************************************************************************
1 plays in revert_changes.yml
PLAY [Revert Windows Server 2012 Configuration] **************************************************************
TASK [Gathering Facts] ***************************************************************************************
task path: /etc/ansible/revert_changes.yml:2
redirecting (type: modules) ansible.builtin.setup to ansible.windows.setup
Using module file /usr/lib/python3/dist-packages/ansible_collections/ansible/windows/plugins/modules/setup.ps1
Pipelining is enabled.
<192.168.1.128> ESTABLISH WINRM CONNECTION FOR USER: Administrator on PORT 5985 TO 192.168.1.128
EXEC (via pipeline wrapper)
ok: [192.168.1.128]
META: ran handlers
TASK [Ensure IIS is removed] *********************************************************************************
task path: /etc/ansible/revert_changes.yml:8
redirecting (type: modules) ansible.builtin.win_feature to ansible.windows.win_feature
Using module file /usr/lib/python3/dist-packages/ansible_collections/ansible/windows/plugins/modules/win_feature.ps1
Pipelining is enabled.
<192.168.1.128> ESTABLISH WINRM CONNECTION FOR USER: Administrator on PORT 5985 TO 192.168.1.128
EXEC (via pipeline wrapper)
changed: [192.168.1.128] => {
    "changed": true,
    "exitcode": "SuccessRestartRequired",
    "feature_result": [
        {
            "display_name": "Common HTTP Features",
            "id": 141,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Default Document",
            "id": 143,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Directory Browsing",
            "id": 144,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Request Filtering",
            "id": 169,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Health and Diagnostics",
            "id": 155,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "HTTP Errors",
            "id": 145,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "HTTP Logging",
            "id": 156,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "IIS Management Console",
            "id": 175,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Management Tools",
            "id": 174,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Performance",
            "id": 171,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Security",
            "id": 162,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Web Server (IIS)",
            "id": 2,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Static Content Compression",
            "id": 172,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Static Content",
            "id": 142,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        },
        {
            "display_name": "Web Server",
            "id": 140,
            "message": [],
            "reboot_required": true,
            "restart_needed": true,
            "skip_reason": "NotSkipped",
            "success": true
        }
    ],
    "reboot_required": true,
    "success": true
}
TASK [Remove sample directory structure] *********************************************************************
task path: /etc/ansible/revert_changes.yml:16
redirecting (type: modules) ansible.builtin.win_file to ansible.windows.win_file
Using module file /usr/lib/python3/dist-packages/ansible_collections/ansible/windows/plugins/modules/win_file.ps1
Pipelining is enabled.
<192.168.1.128> ESTABLISH WINRM CONNECTION FOR USER: Administrator on PORT 5985 TO 192.168.1.128
EXEC (via pipeline wrapper)
changed: [192.168.1.128] => {
    "changed": true
}
TASK [Verify directory removal] ******************************************************************************
task path: /etc/ansible/revert_changes.yml:23
redirecting (type: modules) ansible.builtin.win_shell to ansible.windows.win_shell
Using module file /usr/lib/python3/dist-packages/ansible_collections/ansible/windows/plugins/modules/win_shell.ps1
Pipelining is enabled.
<192.168.1.128> ESTABLISH WINRM CONNECTION FOR USER: Administrator on PORT 5985 TO 192.168.1.128
EXEC (via pipeline wrapper)
changed: [192.168.1.128] => {
    "changed": true,
    "cmd": "Write-Output \"Directory Contents of C:\\Temp:\"
if (Test-Path C:\\Temp) { Get-ChildItem C:\\Temp -Recurse }
else { Write-Output \"C:\\Temp\\AnsibleDemo directory does not exist\" }",
    "delta": "0:00:00.422098",
    "end": "2025-05-21 06:37:41.343238",
    "rc": 0,
    "start": "2025-05-21 06:37:40.921139",
    "stderr": "",
    "stderr_lines": [],
    "stdout": "Directory Contents of C:\\Temp:\r
",
    "stdout_lines": [
        "Directory Contents of C:\\Temp:"
    ]
}
TASK [Display verification results] **************************************************************************
task path: /etc/ansible/revert_changes.yml:30
ok: [192.168.1.128] => {
    "dir_verification.stdout_lines": [
        "Directory Contents of C:\\Temp:"
    ]
}
META: ran handlers
META: ran handlers
PLAY RECAP ***************************************************************************************************
192.168.1.128              : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```