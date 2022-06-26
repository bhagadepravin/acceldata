#!/bin/bash

# For Centos 7

# Setup K8 cluster:
# curl -s https://raw.githubusercontent.com/bhagadepravin/kubernetes/main/k8-setup.sh | sh -s

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update # Make sure we get the latest list of charts
helm list

# Rook
helm repo add rook-release https://charts.rook.io/release
helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph

# rook-ceph-cluster
helm install --create-namespace --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster
kubectl get cephcluster --namespace rook-ceph

echo "Edit rook-ceph-cluster mon mgr"
echo "kubectl edit cephcluster --namespace rook-ceph"
kubectl get all --all-namespaces

# Dashboard:
kubectl apply -f https://raw.githubusercontent.com/karan-kaushik/rook-ceph/main/rook/ceph/ceph-dashboard-loadbalancer.yaml
# https://raw.githubusercontent.com/rook/rook/master/deploy/examples/dashboard-loadbalancer.yaml
kubectl get service/rook-ceph-mgr-dashboard-loadbalancer -n rook-ceph
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo

# toolbox

kubectl create -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/toolbox.yaml
kubectl -n rook-ceph get pod -l "app=rook-ceph-tools"

echo "kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash"
# ceph status
# ceph osd status
# ceph df
# rados df
# kubectl -n rook-ceph delete deployment rook-ceph-tools

# Uninstall  the chart
# helm delete --namespace rook-ceph rook-ceph
# helm delete --namespace rook-ceph rook-ceph-cluster
# kubectl get ns
