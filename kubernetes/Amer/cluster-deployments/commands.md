#Images Available
worker01@worker01:~$ sudo crictl images                            TAG                 IMAGE ID            SIZE
docker.io/library/httpd             latest              4ce47c750a586       58.3MB
docker.io/library/registry          2                   282bd1664cf1f       10.1MB
docker.io/rajchaudhuri/weave-kube   2.9.0               a5de00e95d044       37.2MB
docker.io/rajchaudhuri/weave-npc    2.9.0               0a7dcf6969004       18.8MB
k8s.gcr.io/pause                    3.5                 ed210e3e4a5ba       301kB
registry.k8s.io/kube-proxy          v1.30.8             ce61fda67eb41       29.1MB

#delete image
 sudo crictl rmi 2aa1f6452f09c