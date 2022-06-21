#!/bin/bash
# By: Pravin Bhagade
# Company: Acceldata
# Designation: Staff SRE

# rm -rf torch.sh && wget https://raw.githubusercontent.com/bhagadepravin/acceldata/main/torch.sh && chmod +x torch.sh && ./torch.sh

set -e
set -E

GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'


usage() {
    cat <<EOM
Usage: $(basename $0) [status stop start delete_troch]
  Parameter:
    - ${RED}stop: Will Stop deployments, statefulset, deamonset${NC}
    - ${GREEN}start: Will Start deployments, statefulset, deamonset${NC}
    - ${RED}delete_troch: Will Delete deployments, svc, Kubernetes , docker& K8 config files${NC}
  Examples:
    ./$(basename $0) ${GREEN}status${NC}
    ./$(basename $0) ${RED}stop${NC}
    ./$(basename $0) ${GREEN}start${NC}
    ./$(basename $0) ${RED}delete_torch${NC}
EOM
    exit 0
}
[ -z $1 ] && { usage; }

function status {
kubectl get all --all-namespaces
}
function stop {
         echo "${RED}Stopping torch ${NC}"  
kubectl get deployments.apps -o name | xargs -I % kubectl scale % --replicas=0
kubectl get deployments.apps deployment.apps/torch-query-analyzer | xargs -I % kubectl scale % --replicas=0
kubectl get deployments.apps deployment.apps/torch-reporting | xargs -I % kubectl scale % --replicas=0
kubectl get deploy -n kurl -o name | xargs -I % kubectl scale % --replicas=0 -n kurl
kubectl get deploy -n rook-ceph -o name | xargs -I % kubectl scale % --replicas=0 -n rook-ceph
kubectl get deploy -n spark-operator -o name | xargs -I % kubectl scale % --replicas=0 -n spark-operator
kubectl get deploy -n velero -o name | xargs -I % kubectl scale % --replicas=0 -n velero
kubectl get deploy -n volcano-monitoring -o name | xargs -I % kubectl scale % --replicas=0 -n volcano-monitoring
kubectl get deploy -n volcano-system -o name | xargs -I % kubectl scale % --replicas=0 -n volcano-system
kubectl get deploy -n monitoring -o name | xargs -I % kubectl scale % --replicas=0 -n monitoring

# StatefulSet
kubectl get statefulset -o name | xargs -I % kubectl scale % --replicas=0

# DaemonSet
kubectl get daemonset.apps -n monitoring -o name | xargs -I % kubectl scale % --replicas=0
kubectl get daemonset.apps -n rook-ceph -o name | xargs -I % kubectl scale % --replicas=0
kubectl get daemonset.apps -n velero -o name | xargs -I % kubectl scale % --replicas=0

 echo "${GREEN}TORCH STOPPED${NC}"  
}

function start {
         echo "${RED}Starting torch ${NC}"  
# Deployments
kubectl get deployments.apps -o name | xargs -I % kubectl scale % --replicas=1
kubectl get deployments.apps deployment.apps/torch-query-analyzer | xargs -I % kubectl scale % --replicas=2
kubectl get deployments.apps deployment.apps/torch-reporting | xargs -I % kubectl scale % --replicas=2
kubectl get deploy -n kurl -o name | xargs -I % kubectl scale % --replicas=1 -n kurl
kubectl get deploy -n rook-ceph -o name | xargs -I % kubectl scale % --replicas=1 -n rook-ceph
kubectl get deploy -n spark-operator -o name | xargs -I % kubectl scale % --replicas=1 -n spark-operator
kubectl get deploy -n velero -o name | xargs -I % kubectl scale % --replicas=1 -n velero
kubectl get deploy -n volcano-monitoring -o name | xargs -I % kubectl scale % --replicas=1 -n volcano-monitoring
kubectl get deploy -n volcano-system -o name | xargs -I % kubectl scale % --replicas=1 -n volcano-system
kubectl get deploy -n monitoring -o name | xargs -I % kubectl scale % --replicas=1 -n monitoring

# StatefulSet
kubectl get statefulset -o name | xargs -I % kubectl scale % --replicas=1

# DaemonSet
kubectl get daemonset.apps -n monitoring -o name | xargs -I % kubectl scale % --replicas=1
kubectl get daemonset.apps -n rook-ceph -o name | xargs -I % kubectl scale % --replicas=1
kubectl get daemonset.apps -n velero -o name | xargs -I % kubectl scale % --replicas=1
 echo "${GREEN}TORCH STARTED${NC}"  
}

function delete_torch {
         echo "${RED}Deleting torch ${NC}"  

kubectl delete deployment --all
kubectl delete svc --all
kubeadm reset --force
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
yum remove -y -q docker-ce docker containerd.io
rm -rf /var/lib/docker
yum remove -y -q kubeadm kubectl kubelet kubernetes-cni kube*

rm -rf /usr/local/bin/kubectl*
rm -rf /var/lib/kubelet
rm -rf /var/lib/replicated
rm -rf /var/lib/kurl 
rm -rf  /var/lib/rook 
rm -rf  /opt/replicated/rook
rm -rf ll /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
rm -rf /usr/libexec/kubernetes/kubelet-plugins
rm -rf /data01/acceldata/config/kubernetes
[ -e ~/.kube ] && rm -rf ~/.kube
[ -e /etc/kubernetes ] && rm -rf /etc/kubernetes
[ -e /opt/cni ] && rm -rf /opt/cni

 echo "${GREEN}TORCH DELETED also removed docker completely${NC}"      
}

status
if [ "$1" -eq status ]; then
status $1
fi

stop
if [ "$1" -eq stop ]; then
stop $1
fi

start
if [ "$1" -eq start ]; then
start $1
fi

delete_torch
if [ "$1" -eq delete_torch ]; then
delete_torch $1
fi

