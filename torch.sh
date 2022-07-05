#!/bin/bash
# By: Pravin Bhagade
# Company: Acceldata
# Designation: Staff SRE

# rm -rf torch.sh && wget https://raw.githubusercontent.com/bhagadepravin/acceldata/torch-eks/torch.sh && chmod +x torch.sh && ./torch.sh
set -E

GREEN=$'\e[0;32m'
BLUE=$'\033[0;94m'
YELLOW=$'\033[0;33m'
YELLOW1="\033[38;5;11m"
NC=$'\e[0m'
RESET="\033[0m"
BOLD="\033[1m"

logStep() {
    printf "${BLUE}⚙ $1${NC}\n" 1>&2
}
logWarn() {
    printf "${YELLOW}$1${NC}\n" 1>&2
}

read -e -p "$(echo -e $BOLD$YELLOW1"Complete path of license file="$RESET)" LICENSE
read -e -p "$(echo -e $BOLD$YELLOW1"Provide complete path to config.yaml file="$RESET)" CONFIG
read -e -p "$(echo -e $BOLD$YELLOW1"Provide the namespace which you to use to deploy Torch="$RESET)" NAMESPACE
read -sp "$(echo -e $BOLD$YELLOW1"Pass the shared password="$RESET)" PASSWORD

function confirmN() {
    printf "(y/N) "
    if [ "$ASSUME_YES" = "1" ]; then
        echo "Y"
        return 0
    fi
    if ! prompts_can_prompt; then
        echo "N"
        logWarn "Automatically declining prompt, shell is not interactive"
        return 1
    fi
    prompt
    if [ "$PROMPT_RESULT" = "y" ] || [ "$PROMPT_RESULT" = "Y" ]; then
        return 0
    fi
    return 1
}
function prompts_can_prompt() {
    # Need the TTY to accept input and stdout to display
    # Prompts when running the script through the terminal but not as a subshell
    if [ -t 1 ] && [ -c /dev/tty ]; then
        return 0
    fi
    return 1
}
function prompt() {
    if ! prompts_can_prompt; then
        bail "Cannot prompt, shell is not interactive"
    fi

    set +e
    read PROMPT_RESULT </dev/tty
    set -e
}

function install_torch_eks() {

    if [ "$FORCE_RESET" != 1 ]; then
        printf "\n"
        printf "Info: \n"
        printf "\n"
        printf "    Attempting to install Torch on EKS Cluster.\n"
        printf "\n"
        echo "Complete path of license file=${BLUE}$LICENSE${NC}"
        echo "Complete path of config.yaml file=${BLUE}$CONFIG${NC}"
        echo "Namespace on which torch will be deployed=${BLUE}$NAMESPACE${NC}"
        printf "\n"
        printf "Would you like to continue? "

        if ! confirmN; then
            printf "Not resetting\n"
            exit 1
        fi
    fi

    kubectl get svc -A | grep -q torch-api-gateway1 >/dev/null && echo $?
    if [ $? -eq 0 ]; then
        echo "${GREEN}Torch service pods are already deployed${NC}"
    else
        logStep "Deploying Torch...\n"
        curl https://gitlab.com/api/v4/projects/29750065/repository/files/kots-installer-1.48.0.sh/raw | bash
        kubectl kots install torch --license-file $LICENSE --namespace $NAMESPACE --shared-password $PASSWORD --config-values $CONFIG --port-forward false --skip-rbac-check --skip-preflights --wait-duration 5m
    fi

}
install_torch_eks
