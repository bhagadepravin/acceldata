#!/bin/bash
# By: Pravin Bhagade
# Company: Acceldata
# Designation: Staff SRE

# rm -rf torch.sh && wget https://raw.githubusercontent.com/bhagadepravin/acceldata/main/torch.sh && chmod +x torch.sh && ./torch.sh

# set -e
set -E

RED=$'\e[0;31m'
BLUE='\033[0;94m'
GREEN=$'\e[0;32m'
YELLOW='\033[0;33m'
NC=$'\e[0m'

logSuccess() {
    printf "${GREEN}✔ $1${NC}\n" 1>&2
}
logStep() {
    printf "${BLUE}✔ $1${NC}\n" 1>&2
}
logWarn() {
    printf "${YELLOW}$1${NC}\n" 1>&2
}

usage() {
    cat <<EOM
Usage: $(basename $0) [install_torch_on_prem, status, stop, start, delete_troch]
  Parameter:
    - ${RED}install_torch_on_prem${NC}: Intsall torch-db-kots, kots and admin console torch/db-kots in default namespace
    - ${RED}status${NC}: it will run "kubectl get all --all-namespaces"
    - ${RED}stop${NC}: Will Stop deployments, statefulset, deamonset
    - ${RED}start${NC}: Will Start deployments, statefulset, deamonset
    - ${RED}delete_torch${NC}: Will Delete deployments, svc, Kubernetes , docker& K8 config files
  Examples:
    ./$(basename $0) ${GREEN}install_torch_on_prem${NC}
    ./$(basename $0) ${GREEN}status${NC}
    ./$(basename $0) ${GREEN}stop${NC}
    ./$(basename $0) ${GREEN}start${NC}
    ./$(basename $0) ${RED}delete_torch${NC}                
EOM
    exit 0
}
[ -z $1 ] && { usage; }

function install_torch_on_prem {

    # Disable Swap
    logWarn "Disabling Swap\n"
    cp /etc/fstab /etc/fstab.bak
    swapoff --all
    sed --in-place=.bak '/\bswap\b/ s/^/#/' /etc/fstab

    # Increase LVM size
    logWarn "Increasing LVM size\n"
    yum -y install cloud-utils-growpart && growpart /dev/sda 2
    pvresize /dev/sda2
    lvextend -l+100%FREE /dev/centos/root
    xfs_growfs /dev/centos/root
    lsblk

     logWarn "Checking kubectl package to see kubectl is installed or not p\n"
    rpm -qa | grep kubectl
    if [ $? -eq 0 ]; then
        logSuccess "Torch is Already Installed\n"
    else
        logStep "Installing Torch........\n"
        curl -sSL https://k8s.kurl.sh/torch-db-kots | sudo bash
        curl https://gitlab.com/api/v4/projects/29750065/repository/files/kots-installer-1.48.0.sh/raw | bash
        kubectl kots install torch/db-kots -n default
        logSuccess "Torch is Installed\n"

        logSuccess "Make sure you copy Kotsadm URL and Password. \n"
        logStep "Use this cmd to reset the Kotsadm password --- 'kubectl kots reset-password -n default'\n"
    fi
}

function status {
    logStep "kubectl get pods\n"
    kubectl get pods
    logStep "kubectl get all --all-namespaces\n"
    kubectl get all --all-namespaces
}

function stop {
    echo "${RED} Stopping Torch ${NC}"
    # Deployments
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
    kubectl get job -n rook-ceph -o yaml >/home/job.yaml
    logSuccess "Torch is Stopped\n"
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

    # StatefulSet``
    kubectl get statefulset -o name | xargs -I % kubectl scale % --replicas=1
    kubectl get statefulset -o name alertmanager-prometheus-alertmanager -n monitoring | xargs -I % kubectl scale % --replicas=3 -n monitoring
    kubectl get statefulset -o name -n torch | xargs -I % kubectl scale % --replicas=0 -n torch
    kubectl get statefulset -o name prometheus-k8s -n monitoring | xargs -I % kubectl scale % --replicas=2 -n monitoring

    # DaemonSet
    kubectl -n monitoring patch daemonset prometheus-node-exporter --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
    kubectl -n rook-ceph patch daemonset rook-ceph-agent --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
    kubectl -n rook-ceph patch daemonset rook-discover --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
    kubectl -n velero patch daemonset restic --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
    # kubectl apply -f /home/job.yaml -n rook-ceph
    logSuccess "Torch is Started\n"
}

function delete_torch {
    echo "${RED}Deleting torch ${NC}"

    [ -e /usr/bin/kubectl ] && kubectl kots remove torch -n default --force
    [ -e /usr/bin/kubectl ] && kubectl delete deployment -l app=torch --force
    [ -e /usr/bin/kubectl ] && kubectl delete svc -l app=torch --force
    [ -e /usr/bin/kubectl ] && kubectl delete crd -l app=torch
    [ -e /usr/bin/kubectl ] && kubectl delete pvc -l app=torch --force
    # You need to delete all the resources associated to namespace before deleting the ns
    #[ -e /usr/bin/kubectl ] && kubectl delete ns monitoring kurl rook-ceph spark-operator velero volcano-monitoring volcano-system
    for mount in $(mount | egrep "tmpfs|overlay" | grep '/var/lib' | awk '{ print $3 }') ; do umount $mount; done
    [ -e /usr/bin/kubeadm ] && kubeadm reset --force
    [ -e /usr/bin/kubeadm ] && [ -e /usr/bin/kubectl ] && yum remove -y -q kubeadm kubectl kubelet kubernetes-cni kube*
    #[ -e /usr/bin/docker ] && docker stop $(docker ps -a -q)
    #[ -e /usr/bin/docker ] && docker rm $(docker ps -a -q)
    [ -e /usr/bin/docker ] && yum remove -y docker* containerd.io docker-ce-cli
    [ -e /var/lib/docker ] && rm -rf /var/lib/docker
    [ -e /usr/local/bin/kubectl* ] && rm -rf /usr/local/bin/kubectl*
    [ -e /etc/kubernetes ] && rm -rf /etc/kubernetes
    [ -e /var/lib/replicated ] && rm -rf /var/lib/replicated
    [ -e /var/lib/kurl/addons ] && rm -rf /var/lib/kurl/addons
    [ -e /var/lib/kurl/bin ] && rm -rf /var/lib/kurl/bin
    [ -e /var/lib/kurl/helm ] && rm -rf /var/lib/kurl/helm
    [ -e /var/lib/kurl/host-preflights ] && rm -rf /var/lib/kurl/host-preflights
    [ -e /var/lib/kurl/krew ] && rm -rf /var/lib/kurl/krew
    [ -e /var/lib/kurl/kustomize ] && rm -rf /var/lib/kurl/kustomize
    [ -e /var/lib/kurl/kurlkinds ] && rm -rf /var/lib/kurl/kurlkinds
    [ -e /var/lib/kurl/shared ] && rm -rf /var/lib/kurl/shared
    [ -e /var/lib/rook ] && rm -rf /var/lib/rook
    [ -e /var/log/containers ] && rm -rf /var/log/containers
    [ -e /usr/libexec/kubernetes ] && rm -rf /usr/libexec/kubernetes
    [ -e ~/.kube ] && rm -rf ~/.kube
    [ -e /etc/kubernetes ] && rm -rf /etc/kubernetes
    [ -e /opt/cni ] && rm -rf /opt/cni
    [ -e /var/lib/kubelet ] && rm -rf /var/lib/kubelet

    logSuccess "Torch is DELETED also  docker & K8 is removed completely\n"
    logSuccess "Make sure you Reboot the Node before Reinstalling \n"
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
