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
logSuccess() {
    printf "${GREEN}✔ $1${NC}\n" 1>&2
}


usage() {
    cat <<EOM
Usage: $(basename $0) [status, stop, start, delete_troch, install_torch_on_prem]
  Parameter:
    - ${RED}stop${NC}: Will Stop deployments, statefulset, deamonset
    - ${RED}start${NC}: Will Start deployments, statefulset, deamonset
    - ${RED}delete_torch${NC}: Will Delete deployments, svc, Kubernetes , docker& K8 config files
    - ${RED}install_torch_on_prem${NC}: Intsall torch-db-kots, kots and admin console torch/db-kots in default namespace
  Examples:
    ./$(basename $0) ${GREEN}status${NC}
    ./$(basename $0) ${RED}stop${NC}
    ./$(basename $0) ${GREEN}start${NC}
    ./$(basename $0) ${RED}delete_torch${NC}
    ./$(basename $0) ${GREEN}install_torch_on_prem${NC}
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
kubectl get statefulset -o name -n monitoring | xargs -I % kubectl scale % --replicas=0 -n monitoring
kubectl get statefulset -o name -n torch | xargs -I % kubectl scale % --replicas=0 -n torch

# DaemonSet
kubectl -n monitoring patch daemonset prometheus-node-exporter -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
kubectl -n rook-ceph patch daemonset rook-ceph-agent -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
kubectl -n rook-ceph patch daemonset rook-discover -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
kubectl -n velero patch daemonset restic -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
kubectl get job -n rook-ceph -o yaml > /home/job.yaml
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
kubectl get deploy -n monitoring -o name  | xargs -I % kubectl scale % --replicas=1 -n monitoring

# StatefulSet
kubectl get statefulset -o name | xargs -I % kubectl scale % --replicas=1
kubectl get statefulset -o name  alertmanager-prometheus-alertmanager -n monitoring | xargs -I % kubectl scale % --replicas=3 -n monitoring
kubectl get statefulset -o name -n torch | xargs -I % kubectl scale % --replicas=0 -n torch
kubectl get statefulset -o name prometheus-k8s -n monitoring | xargs -I % kubectl scale % --replicas=2 -n monitoring

# DaemonSet
kubectl -n monitoring patch daemonset prometheus-node-exporter --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
kubectl -n rook-ceph patch daemonset rook-ceph-agent --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
kubectl -n rook-ceph patch daemonset rook-discover --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
kubectl -n velero patch daemonset restic --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
# kubectl apply -f /home/job.yaml -n rook-ceph
 echo "${GREEN}TORCH STARTED${NC}"  
}

function delete_torch {
         echo "${RED}Deleting torch ${NC}"  
kubeadm reset --force
yum remove -y -q kubeadm kubectl kubelet kubernetes-cni kube*
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
yum remove -y -q docker-ce docker containerd.io docker-ce-cli
rm -rf /var/lib/docker
rm -rf /usr/local/bin/kubectl*
rm -rf /var/lib/kubelet
rm -rf /var/lib/replicated
# rm -rf /var/lib/kurl 
rm -rf /var/lib/kurl/addons
rm -rf /var/lib/kurl/bin
rm -rf /var/lib/kurl/helm
rm -rf /var/lib/kurl/host-preflights
rm -rf /var/lib/kurl/krew
rm -rf /var/lib/kurl/kurlkinds
rm -rf /var/lib/kurl/kustomize
rm -rf /var/lib/kurl/shared
rm -rf /var/lib/rook 
rm -rf  /opt/replicated/rook
rm -rf ll /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
rm -rf /usr/libexec/kubernetes/kubelet-plugins
rm -rf /data01/acceldata/config/kubernetes
[ -e ~/.kube ] && rm -rf ~/.kube
[ -e /etc/kubernetes ] && rm -rf /etc/kubernetes
[ -e /opt/cni ] && rm -rf /opt/cni

 echo "${GREEN}TORCH DELETED also removed docker completely${NC}"      
}

function install_torch_on_prem {

cat /etc/fstab | grep --quiet --ignore-case --extended-regexp '^[^#]+swap'
if [ $? -eq 0 ]
    then
        cp  /etc/fstab  /etc/fstab.bak
        swapoff --all
        sed --in-place=.bak '/\bswap\b/ s/^/#/' /etc/fstab
    else
fi

kubectl kots install torch/db-kots -n default

if [ $? -eq 0 ]
    then
        logSuccess "Torch is Already Installed\n"
    else
        echo "${GREEN}Installing Torch........${NC}" 
        curl -sSL https://k8s.kurl.sh/torch-db-kots | sudo bash
        curl https://gitlab.com/api/v4/projects/29750065/repository/files/kots-installer-1.48.0.sh/raw | bash
        kubectl kots install torch/db-kots -n default
        logSuccess "Torch is Installed\n"
fi

}

if [ "$1" == "status" ]; then
status
fi

if [ "$1" == "stop" ]; then
stop
fi

if [ "$1" == "start" ]; then
start
fi

if [ "$1" == "delete_torch" ]; then
delete_torch
fi

if [ "$1" == "install_torch_on_prem" ]; then
install_torch_on_prem
fi
