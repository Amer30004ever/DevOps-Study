# Apply Your Application Configuration:
kubectl apply -f amer-cv-argocd.yaml

at service.yaml file change nodePort: 30080 to 30090

PS git add .\ArgoCD\

PS git commit -m "ArgoCD"
[main e4ea92f] ArgoCD
 1 file changed, 1 insertion(+), 1 deletion(-)
 
PS git push
 
vagrant@helm:~$ kubectl get svc -n amer-cv
NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
amer-cv-service   NodePort   10.98.58.206   <none>        80:30080/TCP   3m9s

vagrant@helm:~$ kubectl get svc -n amer-cv
NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
amer-cv-service   NodePort   10.98.58.206   <none>        80:30090/TCP   3m12s

argocd automatically pulled changes from git and applied it to the Application successfully.