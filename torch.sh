#!/bin/bash
# By: Pravin Bhagade
# Company: Acceldata
# Designation: Staff SRE

# rm -rf torch.sh && wget https://raw.githubusercontent.com/bhagadepravin/acceldata/full-torch/torch.sh && chmod +x torch.sh && ./torch.sh

set -E

RED=$'\e[0;31m'
BLUE=$'\033[0;94m'
GREEN=$'\e[0;32m'
YELLOW=$'\033[0;33m'
NC=$'\e[0m'

logSuccess() {
    printf "${GREEN}✔ e$1${NC}\n" 1>&2
}
logStep() {
    printf "${BLUE}✔ $1${NC}\n" 1>&2
}
logWarn() {
    printf "${YELLOW}$1${NC}\n" 1>&2
}

usage() {
    cat <<EOM
Usage: $(basename $0) [install_torch_full, status, stop, start, delete_troch]
  Parameter:
    - ${BLUE}install_torch_full${NC}: Intsall torch-db-kots, kots and admin console torch/db-kots in default namespace
    - ${BLUE}status${NC}: it will run "kubectl get all --all-namespaces"
    - ${BLUE}stop${NC}: Will Stop deployments, statefulset, deamonset
    - ${BLUE}start${NC}: Will Start deployments, statefulset, deamonset
    - ${BLUE}prep_node${NC}: Disable Swap and Expand LVM(for a New Node)
    - ${BLUE}delete_torch${NC}: Will Delete deployments, svc, Kubernetes , docker& K8 config files
  Examples:
    ./$(basename $0) ${GREEN}install_torch_full${NC}
    ./$(basename $0) ${GREEN}status${NC}
    ./$(basename $0) ${GREEN}stop${NC}
    ./$(basename $0) ${GREEN}start${NC}
    ./$(basename $0) ${YELLOW}prep_node${NC}
    ./$(basename $0) ${RED}delete_torch${NC}                
EOM
    exit 0
}
[ -z $1 ] && { usage; }

function diasble_swap {
    logWarn "Disabling Swap\n"
    cp /etc/fstab /etc/fstab.bak
    swapoff --all
    sed --in-place=.bak '/\bswap\b/ s/^/#/' /etc/fstab
}

function increase_LVM {
    logWarn "Increasing LVM size\n"
    yum -y -q install cloud-utils-growpart && growpart /dev/sda 2
    pvresize /dev/sda2
    lvextend -l+100%FREE /dev/centos/root
    xfs_growfs /dev/centos/root
    lsblk
}

function install_torch_full {
    logStep "Installing Torch........\n"
    #curl -sSL https://k8s.kurl.sh/torch-db-kots | sudo bash
    curl -sSL https://k8s.kurl.sh/torch-pre-sales | sudo bash
    [ -e ~/complete_config.yaml ] && mv ~/complete_config.yaml ~/complete_config.yaml.bk
    wget -P ~/ https://bitbucket.org/pravinbhagade/testing/raw/8029c47d6471506112a00b1e63279a13c3e2ec25/complete_config.yaml
    IPADDRESS=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
    sed -i "s/IPADDRESS/${IPADDRESS}/g" ~/complete_config.yaml
    wget -P ~/ https://bitbucket.org/pravinbhagade/testing/raw/83fba69a058e606d8ca717dda68f312d947f3221/inhouse-pre-sales-department.yaml
    curl https://gitlab.com/api/v4/projects/29750065/repository/files/kots-installer-1.48.0.sh/raw | bash
    kubectl kots install torch --license-file ~/inhouse-pre-sales-department.yaml --namespace torch-auto --shared-password Acceldata123 --config-values ~/complete_config.yaml --port-forward false --skip-preflights

    logSuccess "Torch is Installed\n"
    logSuccess "http://${IPADDRESS}:/torch"
    logSuccess "Make sure you copy Kotsadm URL and Password. \n"
    logStep "Use this cmd to reset the Kotsadm password --- 'kubectl kots reset-password -n default'\n"
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
    # kubectl delete jobs -all
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
    [ -e /usr/bin/kubectl ] && kubectl delete deployment --all
    for mount in $(mount | egrep "/dev|tmpfs|overlay" | grep '/var/lib' | awk '{ print $3 }'); do umount -l $mount; done
    [ -e /usr/bin/kubeadm ] && kubeadm reset --force
    #[ -e /usr/bin/docker ] && docker stop $(docker ps -a -q)
    [ -e /usr/bin/docker ] && docker rm $(docker ps -a -q)
    [ -e /usr/bin/docker ] && docker system prune --force
    [ -e /usr/bin/docker ] && docker network prune --force
    yum remove -q -y docker-ce docker containerd.io && rm -rf /var/lib/docker > /dev/null
    yum remove -q -y kubeadm kubectl kubelet kubernetes-cni kube* && rm -rf /usr/bin/kubeadm 
    [ -e /usr/local/bin/kubectl ] && rm -rf /usr/local/bin/kubectl
    [ -e /var/lib/kubelet ] && rm -rf /var/lib/kubelet
    [ -e /var/lib/replicated ] && rm -rf /var/lib/replicated
    [ -e /var/lib/kurl/addons ] && rm -rf /var/lib/kurl/addons
    [ -e /var/lib/kurl/bin ] && rm -rf /var/lib/kurl/bin
    [ -e /var/lib/kurl/helm ] && rm -rf /var/lib/kurl/helm
    [ -e /var/lib/kurl/host-preflights ] && rm -rf /var/lib/kurl/host-preflights
    [ -e /var/lib/kurl/krew ] && rm -rf /var/lib/kurl/krew
    [ -e /var/lib/kurl/kustomize ] && rm -rf /var/lib/kurl/kustomize
    [ -e /var/lib/kurl/packages ] && rm -rf /var/lib/kurl/packages
    [ -e /var/lib/kurl/tmp-kubeadm.conf ] && rm -rf /var/lib/kurl/tmp-kubeadm.conf
    [ -e /var/lib/kurl/kurlkinds ] && rm -rf /var/lib/kurl/kurlkinds
    [ -e /var/lib/kurl/shared ] && rm -rf /var/lib/kurl/shared
    [ -e /var/lib/rook ] && rm -rf /var/lib/rook
    [ -e /opt/replicated/rook ] && rm rm -rf /opt/replicated/rook
    [ -e /usr/libexec/kubernetes/kubelet-plugins/volume/exec/ ] && rm -rf /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
    [ -e /usr/libexec/kubernetes/kubelet-plugins ] && rm -rf /usr/libexec/kubernetes/kubelet-plugins
    [ -e /data01/acceldata/config/kubernetes ] && rm -rf /data01/acceldata/config/kubernetes
    [ -e /var/lib/etcd ] && rm -rf /var/lib/etcd
    [ -e /var/lib/weave ] && rm -rf /var/lib/weave
    [ -e ~/.kube ] && rm -rf ~/.kube
    [ -e /etc/kubernetes ] && rm -rf /etc/kubernetes
    [ -e /opt/cni ] && rm -rf /opt/cni

    ip link delete docker0

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

if [ "$1" == "install_torch_full" ]; then
    install_torch_full
fi
if [ "$1" == "prep_node" ]; then
    diasble_swap
    increase_LVM
fi
