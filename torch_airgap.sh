#!/usr/bin/env bash
# Pravin Bhagade
#Setup Troch Script for Airgapped Installation.

set -E
GREEN=$'\e[0;32m'
BLUE=$'\033[0;94m'
YELLOW=$'\033[0;33m'
YELLOW1="\033[38;5;11m"
RED=$'\033[0;31m'
NC=$'\e[0m'
RESET="\033[0m"
BOLD="\033[1m"
Cyan=$'\033[0;36m'
ICyan=$'\033[0;96m'
Purple=$'\033[0;35m'

logStep() {
  printf "${BLUE}⚙ $1${NC}\n" 1>&2
}
logWarn() {
  printf "${YELLOW}$1${NC}\n" 1>&2
}

usage() {
  cat <<EOM
    ${ICyan}
       __    ___  ___  ____  __    ____    __   ____   __   
      /__\  / __)/ __)( ___)(  )  (  _ \  /__\ (_  _) /__\  
     /(__)\( (__( (__  )__) ) (_   )(_) )/(__)\  )(  /(__)\ 
    (__)(__)\___)\___)(____)(____)(____/(__)(__)(__)(__)(__)
    ${NC} 

  ${Cyan}/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${NC}
  Usage: $(basename $0)  ${YELLOW}[prerequisite, minimum_rbac, torch_airgap_upload, torch_install....]${NC}
  ${Purple} Parameter:${NC}
    - ${BLUE}prerequisite${NC}:...............Check kubectl, kubectl-kots, Gather necessary infomation.
    - ${BLUE}minimum_rbac${NC}:...............Guidelines for minimum_rbac setup for k8 cluster.
    - ${BLUE}torch_airgap_upload${NC}:........Commmand to upload torch airgap bundle.
    - ${BLUE}torch_minimum_rbac_install${NC}:.Install Torch with Minimum RBAC priviligies for the service account.
    - ${BLUE}torch_install${NC}:..............Install Torch will full priviligies user.
    - ${BLUE}uninstall_torch${NC}:............Uninstall Torch.

  ${Purple} Examples:${NC}
    ./$(basename $0) ${GREEN}prerequisite${NC}
    ./$(basename $0) ${GREEN}minimum_rbac${NC}
    ./$(basename $0) ${GREEN}torch_airgap_upload${NC}
    ./$(basename $0) ${GREEN}torch_minimum_rbac_install${NC}
    ./$(basename $0) ${GREEN}torch_install${NC}
    ./$(basename $0) ${RED}uninstall_torch${NC}

  ${Cyan} /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${NC}

EOM
  exit 0
}
[ -z $1 ] && { usage; }

function prerequisite {
  which kubectl 2>/dev/null >/dev/null && echo "kubectl utility present" || echo "kubectl not present, Please install **kubectl** Ref: https://kubernetes.io/docs/tasks/tools/"
  [ -f /usr/local/bin/kubectl-kots ] && echo "kubectl-kots exists." || echo "kubectl-kots does not exists." && echo "Install kubectl-kots --> curl https://kots.io/install/1.84.0 | bash"
  logWarn "Please make sure have below infomation from your Private Registry"
  logWarn " Private Registry URL, TOKEN, username, Repository Name(will be used to upload images from airgap bundle)"
  logWarn "DNS hostname/url for torch UI"
  logWarn "Download Airgap bundle"
  logWarn "kubernetes User used to install torch make sure it admin priviligies or Minimum RBAC"
}

function minimum_rbac {
  logWarn "Please share miminum-rbac.yml which is namespace scoped to K8 admin team"
  logWarn "Please Create necessary CRD's required for torch setup"
}

function torch_airgap_upload {
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path of KOTS Airgap Bundle tar file(kotsadm.tar.gz)="$RESET)" KOTSADM
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path of TORCH Airgap Bundle (.airgap)="$RESET)" TORCH
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide Private registry URL="$RESET)" URL
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide Private registry Repository Name="$RESET)" REPOSITORY
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide Private registry Repository Username="$RESET)" USERNAME
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide Private registry Repository TOKEN="$RESET)" TOKEN

  logStep "Use/copy below cmd to push images to Private registry"
  logStep "Upload KOTS Airgap Bundle"
  echo "kubectl kots admin-console push-images $KOTSADM $URL/$REPOSITORY --registry-username $USERNAME --registry-password ${TOKEN}"

  logStep "Upload Torch Airgap Bundle"
  echo "kubectl kots admin-console push-images $TORCH $URL/$REPOSITORY --registry-username $USERNAME --registry-password ${TOKEN}"

}

function torch_minimum_rbac_install {
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path of license file="$RESET)" LICENSE
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path to config.yaml file="$RESET)" CONFIG
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide a namespace to deploy Torch="$RESET)" NAMESPACE
  read -sp "$(echo -e $BOLD$YELLOW1"Pass the shared password="$RESET)" PASSWORD

  logStep "kubectl kots install torch --license-file $LICENSE --namespace $NAMESPACE --shared-password $PASSWORD --config-values $CONFIG --ensure-rbac=false --disable-image-push --wait-duration 30m --skip-rbac-check --skip-preflights"
}

function torch_install {
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path of license file="$RESET)" LICENSE
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path to config.yaml file="$RESET)" CONFIG
  read -e -p "$(echo -e $BOLD$YELLOW1"Provide a namespace to deploy Torch="$RESET)" NAMESPACE
  read -sp "$(echo -e $BOLD$YELLOW1"Pass the shared password="$RESET)" PASSWORD

  logStep "kubectl kots install torch --license-file $LICENSE --namespace $NAMESPACE --shared-password $PASSWORD --config-values $CONFIG --skip-rbac-check --skip-preflights --wait-duration 30m"
}

function uninstall_torch {
  echo "uninstall_torch"
}

if [ "$1" == "prerequisite" ]; then
    prerequisite
fi

if [ "$1" == "minimum_rbac" ]; then
    minimum_rbac
fi

if [ "$1" == "torch_airgap_upload" ]; then
    torch_airgap_upload
fi

if [ "$1" == "torch_minimum_rbac_install" ]; then
    torch_minimum_rbac_install
fi

if [ "$1" == "torch_install" ]; then
    torch_install
fi

if [ "$1" == "uninstall_torch" ]; then
    uninstall_torch
fi
