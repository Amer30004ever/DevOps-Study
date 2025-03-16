Verify Network Connectivity
Ensure that the HAProxy machine (192.168.2.166) can reach the master nodes
 (192.168.2.161, 192.168.2.162, 192.168.2.163) on port 6443.

Run the following commands from the HAProxy machine:

nc -zv 192.168.2.161 6443
nc -zv 192.168.2.162 6443
nc -zv 192.168.2.163 6443


systemctl status haproxy

If any connections fail, check the firewall rules on the nodes to ensure port 6443 is open:

sudo ufw allow 6443/tcp