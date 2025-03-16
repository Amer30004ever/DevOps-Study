#show images on kubernetes machine
sudo crictl images

#IMAGE                               TAG             IMAGE ID            SIZE
#docker.io/library/nginx             latest          97662d24417b3       72.2MB
docker.io/amer30004ever/proj                latest              36cbdf1f9fb4b       97.7MB
docker.io/grafana/grafana                   latest              3344a121f4493       147MB
docker.io/prom/prometheus                   latest              a977124a660f0       117MB
quay.io/argoproj/argocd                     v2.13.2             276c7ef97554a       180MB

#Export Images Using ctr
sudo ctr -n k8s.io images export nginx-latest.tar docker.io/library/nginx:latest
sudo ctr -n k8s.io images export amer30004ever-proj-latest.tar docker.io/amer30004ever/proj:latest
sudo ctr -n k8s.io images export grafana-grafana-latest.tar docker.io/grafana/grafana:latest
sudo ctr -n k8s.io images export prom-prometheus-latest.tar docker.io/prom/prometheus:latest
sudo ctr -n k8s.io images export argoproj-argocd-v2.13.2.tar quay.io/argoproj/argocd:v2.13.2

#Transfer the Tarballs
scp nginx-latest.tar registry@192.168.2.139:/home/registry
scp amer30004ever-proj-latest.tar registry@192.168.2.139:/home/registry
scp grafana-grafana-latest.tar registry@192.168.2.139:/home/registry
scp prom-prometheus-latest.tar registry@192.168.2.139:/home/registry
scp argoproj-argocd-v2.13.2.tar registry@192.168.2.139:/home/registry

#Import the image on the registry machine:
docker load -i nginx-latest.tar
docker load -i /home/registry/amer30004ever-proj-latest.tar
docker load -i /home/registry/grafana-grafana-latest.tar
docker load -i /home/registry/prom-prometheus-latest.tar
docker load -i /home/registry/argoproj-argocd-v2.13.2.tar

#Show images:
docker image ls