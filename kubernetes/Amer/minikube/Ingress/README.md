vagrant@helm:~$ kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   130m

vagrant@helm:~$ kubectl create deployment nginxservice --image nginx:latest
deployment.apps/nginxservice created

vagrant@helm:~$ kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/nginxservice-7b9779cc87-znzsb   1/1     Running   0          51s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   157m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginxservice   1/1     1            1           51s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginxservice-7b9779cc87   1         1         1       51s

vagrant@helm:~$ kubectl scale deploy nginxservice --replicas 4
deployment.apps/nginxservice scaled

vagrant@helm:~$ kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/nginxservice-7b9779cc87-cwtzp   1/1     Running   0          17s
pod/nginxservice-7b9779cc87-nx7q6   1/1     Running   0          17s
pod/nginxservice-7b9779cc87-trbnc   1/1     Running   0          17s
pod/nginxservice-7b9779cc87-znzsb   1/1     Running   0          2m2s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   158m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginxservice   4/4     4            4           2m2s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginxservice-7b9779cc87   4         4         4       2m2s

vagrant@helm:~$ kubectl expose deploy nginxservice --port 80 --type NodePort
service/nginxservice exposed

vagrant@helm:~$ kubectl get svc
NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.96.0.1      <none>        443/TCP        13h
nginxservice   NodePort    10.98.223.39   <none>        80:30624/TCP   16s

vagrant@helm:~$ kubectl create ingress nginxsrvice-ingress --rule "/=nginxservice:80"
ingress.networking.k8s.io/nginxsrvice-ingress created

vagrant@helm:~$ kubectl get ingress
NAME                  CLASS   HOSTS   ADDRESS        PORTS   AGE
nginxsrvice-ingress   nginx   *       192.168.49.2   80      16s

vagrant@helm:~$ minikube ip
192.168.49.2

vagrant@helm:~$ minikube ssh

docker@minikube:~$ sudo /bin/sh -c 'echo "192.168.49.2 nginxservice.io" >> /etc/hosts'

docker@minikube:~$ curl nginxservice.io
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

docker@minikube:~$ cat /etc/hosts
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.49.2    minikube
192.168.49.1    host.minikube.internal
192.168.49.2    control-plane.minikube.internal
192.168.49.2 nginxservice.io

docker@minikube:~$ exit
logout

vagrant@helm:~$ kubectl describe ingress nginxsrvice-ingress
Name:             nginxsrvice-ingress
Labels:           <none>
Namespace:        default
Address:          192.168.49.2
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /   nginxservice:80 (10.244.0.67:80,10.244.0.68:80,10.244.0.69:80 + 1 more...)
Annotations:  <none>
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    22m (x2 over 22m)  nginx-ingress-controller  Scheduled for sync

vagrant@helm:~$ kubectl edit ingress nginxsrvice-ingress
Edit cancelled, no changes made.

#delete all
kubectl delete ingress nginxsrvice-ingress
kubectl delete service nginxservice
kubectl delete deployment nginxservice
kubectl get all
------------------------------------------------------------------
vagrant@helm:~$ kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   10m

vagrant@helm:~$ kubectl create deployment app1 --image httpd:latest
deployment.apps/app1 created

vagrant@helm:~$ kubectl create deployment app2 --image gcr.io/google-samples/hello-app:1.0
deployment.apps/app2 created

vagrant@helm:~$ kubectl create deployment app3 --image gcr.io/google-samples/hello-app:2.0
deployment.apps/app3 created

vagrant@helm:~$ kubectl get all
NAME                        READY   STATUS              RESTARTS   AGE
pod/app1-679f476bb-2qhgf    0/1     ContainerCreating   0          33s
pod/app2-77764c9db6-ptdpm   0/1     ContainerCreating   0          13s
pod/app3-674cfbd4b4-p2wmg   0/1     ContainerCreating   0          8s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   11m

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app1   0/1     1            0           33s
deployment.apps/app2   0/1     1            0           13s
deployment.apps/app3   0/1     1            0           8s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/app1-679f476bb    1         1         0       33s
replicaset.apps/app2-77764c9db6   1         1         0       13s
replicaset.apps/app3-674cfbd4b4   1         1         0       8s

vagrant@helm:~$ kubectl scale deployment app1 --replicas=6
deployment.apps/app1 scaled

vagrant@helm:~$ kubectl scale deployment app2 --replicas=5
deployment.apps/app2 scaled

vagrant@helm:~$ kubectl scale deployment app3 --replicas=4
deployment.apps/app3 scaled

vagrant@helm:~$ kubectl get deployment
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
app1   1/6     6            1           60s
app2   0/5     5            0           40s
app3   0/4     4            0           35s

vagrant@helm:~$ kubectl get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/app1-679f476bb-2qhgf    1/1     Running   0          6m25s
pod/app1-679f476bb-8zdzc    1/1     Running   0          5m38s
pod/app1-679f476bb-8zrcf    1/1     Running   0          5m38s
pod/app1-679f476bb-dt4wd    1/1     Running   0          5m38s
pod/app1-679f476bb-fq5qq    1/1     Running   0          5m38s
pod/app1-679f476bb-fqhz8    1/1     Running   0          5m38s
pod/app2-77764c9db6-452vv   1/1     Running   0          5m33s
pod/app2-77764c9db6-6gkdd   1/1     Running   0          5m34s
pod/app2-77764c9db6-ptdpm   1/1     Running   0          6m5s
pod/app2-77764c9db6-r6hrd   1/1     Running   0          5m34s
pod/app2-77764c9db6-x6t8s   1/1     Running   0          5m34s
pod/app3-674cfbd4b4-j82kf   1/1     Running   0          5m30s
pod/app3-674cfbd4b4-l97mm   1/1     Running   0          5m30s
pod/app3-674cfbd4b4-p2wmg   1/1     Running   0          6m
pod/app3-674cfbd4b4-rhnzn   1/1     Running   0          5m30s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17m

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app1   6/6     6            6           6m25s
deployment.apps/app2   5/5     5            5           6m5s
deployment.apps/app3   4/4     4            4           6m

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/app1-679f476bb    6         6         6       6m25s
replicaset.apps/app2-77764c9db6   5         5         5       6m5s
replicaset.apps/app3-674cfbd4b4   4         4         4       6m

vagrant@helm:~$ kubectl expose deployment app1 --port=80 --type=NodePort
service/app1 exposed

vagrant@helm:~$ kubectl expose deployment app2 --port=8080 --type=NodePort
service/app2 exposed

vagrant@helm:~$ kubectl expose deployment app3 --port=8080 --type=NodePort
service/app3 exposed

vagrant@helm:~$ kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
app1         NodePort    10.108.226.203   <none>        80:30517/TCP     18s
app2         NodePort    10.100.130.157   <none>        8080:32591/TCP   9s
app3         NodePort    10.111.196.125   <none>        8080:31514/TCP   5s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          17m

vagrant@helm:~$ minikube service app1
|-----------|------|-------------|---------------------------|
| NAMESPACE | NAME | TARGET PORT |            URL            |
|-----------|------|-------------|---------------------------|
| default   | app1 |          80 | http://192.168.49.2:30517 |
|-----------|------|-------------|---------------------------|
* Opening service default/app1 in default browser...
  http://192.168.49.2:30517
  
vagrant@helm:~$ minikube service app1 --url
http://192.168.49.2:30517

vagrant@helm:~$ minikube service app2
|-----------|------|-------------|---------------------------|
| NAMESPACE | NAME | TARGET PORT |            URL            |
|-----------|------|-------------|---------------------------|
| default   | app2 |        8080 | http://192.168.49.2:32591 |
|-----------|------|-------------|---------------------------|
* Opening service default/app2 in default browser...
  http://192.168.49.2:32591
  
vagrant@helm:~$ minikube service app3
|-----------|------|-------------|---------------------------|
| NAMESPACE | NAME | TARGET PORT |            URL            |
|-----------|------|-------------|---------------------------|
| default   | app3 |        8080 | http://192.168.49.2:31514 |
|-----------|------|-------------|---------------------------|
* Opening service default/app3 in default browser...
  http://192.168.49.2:31514

vagrant@helm:~$ curl http://192.168.49.2:30517
<html><body><h1>It works!</h1></body></html>

vagrant@helm:~$ curl http://192.168.49.2:32591
Hello, world!
Version: 1.0.0
Hostname: app2-77764c9db6-452vv

vagrant@helm:~$ curl http://192.168.49.2:31514
Hello, world!
Version: 2.0.0
Hostname: app3-674cfbd4b4-l97mm

#Ingress

vagrant@helm:~$ minikube addons enable ingress
* ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4
  - Using image registry.k8s.io/ingress-nginx/controller:v1.11.3
  - Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.4
* Verifying ingress addon...
* The 'ingress' addon is enabled

vagrant@helm:~$ sudo vi fanout.yaml 

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multiapp-ingress
spec:
  rules:
  - host: amer.devops
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2
            port:
              number: 8080
      - path: /app3
        pathType: Prefix
        backend:
          service:
            name: app3
            port:
              number: 8080

vagrant@helm:~$ kubectl apply -f fanout.yaml
ingress.networking.k8s.io/multiapp-ingress created

vagrant@helm:~$ minikube ssh

docker@minikube:~$ sudo /bin/sh -c 'echo "192.168.49.2 amer.devops" >> /etc/hosts'

docker@minikube:~$ curl amer.devops
<html><body><h1>It works!</h1></body></html>

docker@minikube:~$ curl amer.devops/app2
Hello, world!
Version: 1.0.0
Hostname: app2-77764c9db6-dv4gj

docker@minikube:~$ curl amer.devops/app3
Hello, world!
Version: 2.0.0
Hostname: app3-674cfbd4b4-qqzhr

#delete all
kubectl delete ingress multiapp-ingress
kubectl delete service app1 app2 app3
kubectl delete deployment app1 app2 app3
kubectl get all
--------------------------------------------------------
vagrant@helm:~$ kubectl create deploy zain --image=nginx
deployment.apps/zain created

vagrant@helm:~$ kubectl create deploy saif --image httpd
deployment.apps/saif created

vagrant@helm:~$ kubectl expose deploy zain --port 80
service/zain exposed

vagrant@helm:~$ kubectl expose deploy saif --port 80
service/saif exposed

vagrant@helm:~$ kubectl get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/saif-6849586d4b-86bmg   1/1     Running   0          10s
pod/zain-84c965b5d9-st77z   1/1     Running   0          38s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   14h
service/saif         ClusterIP   10.106.12.231   <none>        80/TCP    10s
service/zain         ClusterIP   10.105.18.134   <none>        80/TCP    38s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/saif   1/1     1            1           10s
deployment.apps/zain   1/1     1            1           39s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/saif-6849586d4b   1         1         1       10s
replicaset.apps/zain-84c965b5d9   1         1         1       39s

vagrant@helm:~$ minikube ssh

docker@minikube:~$ sudo /bin/sh -c 'echo "192.168.49.2 zain.k8s" >> /etc/hosts'

docker@minikube:~$ sudo /bin/sh -c 'echo "192.168.49.2 saif.k8s" >> /etc/hosts'

docker@minikube:~$ cat /etc/hosts
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.49.2    minikube
192.168.49.1    host.minikube.internal
192.168.49.2    control-plane.minikube.internal
192.168.49.2 zain.k8s
192.168.49.2 saif.k8s

docker@minikube:~$ kubectl create ingress kubernetes-ingress --rule "zain.k8s/=zain:80" --rule "saif.k8s/=saif:80"^C

docker@minikube:~$ exit
logout
ssh: Process exited with status 130
vagrant@helm:~$ kubectl create ingress kubernetes-ingress --rule "zain.k8s/=zain:80" --rule "saif.k8s/=saif:80"
ingress.networking.k8s.io/kubernetes-ingress created

vagrant@helm:~$ minikube ssh

docker@minikube:~$ curl zain.k8s
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

docker@minikube:~$ curl saif.k8s
<html><body><h1>It works!</h1></body></html>

vagrant@helm:~$ kubectl delete all --all -n default
pod "saif-6849586d4b-86bmg" deleted
pod "zain-84c965b5d9-st77z" deleted
service "kubernetes" deleted
service "saif" deleted
service "zain" deleted
deployment.apps "saif" deleted
deployment.apps "zain" deleted
replicaset.apps "zain-84c965b5d9" deleted
