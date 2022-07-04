#!/bin/bash

set -e

commandExists() {
    command -v "$@" > /dev/null 2>&1
}

function get_weave_version() {
    local weave_version=$(KUBECONFIG=/etc/kubernetes/admin.conf kubectl get daemonset -n kube-system weave-net -o jsonpath="{..spec.containers[0].image}" | sed 's/^.*://')
    if [ -z "$weave_version" ]; then
        if [ -n "$DOCKER_VERSION" ]; then
            weave_version=$(docker image ls | grep kurlsh/weave-npc | awk '{ print $2 }' | head -1)
            if [ -z "$weave_version" ]; then
                weave_version=$(docker image ls | grep weaveworks/weave-npc | awk '{ print $2 }' | head -1)
            fi
        else
            weave_version=$(crictl images list | grep kurlsh/weave-npc | awk '{ print $2 }' | head -1)
            if [ -z "$weave_version" ]; then
                weave_version=$(crictl images list | grep weaveworks/weave-npc | awk '{ print $2 }' | head -1)
            fi
        fi
        if [ -z "$weave_version" ]; then
            # if we don't know the exact weave tag, use a sane default
            weave_version="2.6.5"
        fi
    fi
    echo $weave_version
}

function confirmN() {
    printf "(y/N) "
    if [ "$ASSUME_YES" = "1" ]; then
        echo "Y"
        return 0
    fi
    if ! prompts_can_prompt ; then
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
    if ! prompts_can_prompt ; then
        bail "Cannot prompt, shell is not interactive"
    fi

    set +e
    read PROMPT_RESULT < /dev/tty
    set -e
}
function kubernetes_resource_exists() {
    local namespace=$1
    local kind=$2
    local name=$3

    kubectl -n "$namespace" get "$kind" "$name" &>/dev/null
}

semverParse() {
    major="${1%%.*}"
    minor="${1#$major.}"
    minor="${minor%%.*}"
    patch="${1#$major.$minor.}"
    patch="${patch%%[-.]*}"
}

function kubeadm_discover_private_ip() {
    local private_address

    private_address="$(cat /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null | grep advertise-address | awk -F'=' '{ print $2 }')"

    # This is needed on k8s 1.18.x as $PRIVATE_ADDRESS is found to have a newline
    echo "${private_address}" | tr -d '\n'
}

function kubeadm_get_kubeconfig() {
    echo "/etc/kubernetes/admin.conf"
}

function kubeadm_get_containerd_sock() {
    echo "/run/containerd/containerd.sock"

}
# Run a test every second with a spinner until it succeeds
function spinner_until() {
    local timeoutSeconds="$1"
    local cmd="$2"
    local args=${@:3}

    if [ -z "$timeoutSeconds" ]; then
        timeoutSeconds=-1
    fi

    local delay=1
    local elapsed=0
    local spinstr='|/-\'

    while ! $cmd $args; do
        elapsed=$(($elapsed + $delay))
        if [ "$timeoutSeconds" -ge 0 ] && [ "$elapsed" -gt "$timeoutSeconds" ]; then
            return 1
        fi
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
}

# Checks if the provided param is in the current path, and if it is not adds it
# this is useful for systems where /usr/local/bin is not in the path for root


function get_docker_version() {
    if ! commandExists "docker" ; then
        return
    fi
    docker -v | awk '{gsub(/,/, "", $3); print $3}'
}

function kubernetes_drain() {
    kubectl drain "$1" \
        --delete-local-data \
        --ignore-daemonsets \
        --force \
        --grace-period=30 \
        --timeout=120s \
        --pod-selector 'app notin (rook-ceph-mon,rook-ceph-osd,rook-ceph-osd-prepare,rook-ceph-operator,rook-ceph-agent),k8s-app!=kube-dns' || true
}

function kubernetes_scale_down() {
    local ns="$1"
    local kind="$2"
    local name="$3"

    if ! kubernetes_resource_exists "$ns" "$kind" "$name"; then
        return 0
    fi

    kubectl -n "$ns" scale "$kind" "$name" --replicas=0
}
function reset_dnf_module_kurl_local() {
    if ! commandExists dnf; then
        return
    fi
    if ! dnf module list | grep -q kurl.local ; then
        return
    fi
    yum module reset -y kurl.local
}


PV_BASE_PATH=/opt/replicated/rook



function kubeadm_reset() {
    if [ -z "$WEAVE_TAG" ]; then
        WEAVE_TAG="$(get_weave_version)"
    fi

    if [ -n "$DOCKER_VERSION" ]; then
        kubeadm reset --force
    else
        kubeadm reset --force --cri-socket /var/run/containerd/containerd.sock
    fi
    printf "kubeadm reset completed\n"

    if [ -f /etc/cni/net.d/10-weave.conflist ]; then
        kubeadm_weave_reset
    fi
    printf "weave reset completed\n"
}

function kubeadm_weave_reset() {
    BRIDGE=weave
    DATAPATH=datapath
    CONTAINER_IFNAME=ethwe

    DOCKER_BRIDGE=docker0

    WEAVEEXEC_IMAGE="weaveworks/weaveexec"

    kurlshWeaveVersionPattern='^[0-9]+\.[0-9]+\.[0-9]+-(.*)-(20)[0-9]{6}$'
    if [[ $WEAVE_TAG =~ $kurlshWeaveVersionPattern ]] ; then
        WEAVEEXEC_IMAGE="kurlsh/weaveexec"
    fi

    # https://github.com/weaveworks/weave/blob/v2.8.1/weave#L461
    for NETDEV in $BRIDGE $DATAPATH ; do
        if [ -d /sys/class/net/$NETDEV ] ; then
            if [ -d /sys/class/net/$NETDEV/bridge ] ; then
                ip link del $NETDEV
            else
                if [ -n "$DOCKER_VERSION" ]; then
                    docker run --rm --pid host --net host --privileged --entrypoint=/usr/bin/weaveutil $WEAVEEXEC_IMAGE:$WEAVE_TAG delete-datapath $NETDEV
                else
                    # --pid host
                    local guid=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c16)
                    # TODO(ethan): rke2 containerd.sock path is incorrect
                    ctr -n=k8s.io run --rm --net-host --privileged docker.io/$WEAVEEXEC_IMAGE:$WEAVE_TAG $guid /usr/bin/weaveutil delete-datapath $NETDEV
                fi
            fi
        fi
    done

    # Remove any lingering bridged fastdp, pcap and attach-bridge veths
    for VETH in $(ip -o link show | grep -o v${CONTAINER_IFNAME}[^:@]*) ; do
        ip link del $VETH >/dev/null 2>&1 || true
    done

    if [ "$DOCKER_BRIDGE" != "$BRIDGE" ] ; then
        kubeadm_run_iptables -t filter -D FORWARD -i $DOCKER_BRIDGE -o $BRIDGE -j DROP 2>/dev/null || true
    fi

    kubeadm_run_iptables -t filter -D INPUT -d 127.0.0.1/32 -p tcp --dport 6784 -m addrtype ! --src-type LOCAL -m conntrack ! --ctstate RELATED,ESTABLISHED -m comment --comment "Block non-local access to Weave Net control port" -j DROP >/dev/null 2>&1 || true
    kubeadm_run_iptables -t filter -D INPUT -i $DOCKER_BRIDGE -p udp --dport 53  -j ACCEPT  >/dev/null 2>&1 || true
    kubeadm_run_iptables -t filter -D INPUT -i $DOCKER_BRIDGE -p tcp --dport 53  -j ACCEPT  >/dev/null 2>&1 || true

    if [ -n "$DOCKER_VERSION" ]; then
        DOCKER_BRIDGE_IP=$(docker run --rm --pid host --net host --privileged -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=/usr/bin/weaveutil $WEAVEEXEC_IMAGE:$WEAVE_TAG bridge-ip $DOCKER_BRIDGE)

        kubeadm_run_iptables -t filter -D INPUT -i $DOCKER_BRIDGE -p tcp --dst $DOCKER_BRIDGE_IP --dport $PORT          -j DROP >/dev/null 2>&1 || true
        kubeadm_run_iptables -t filter -D INPUT -i $DOCKER_BRIDGE -p udp --dst $DOCKER_BRIDGE_IP --dport $PORT          -j DROP >/dev/null 2>&1 || true
        kubeadm_run_iptables -t filter -D INPUT -i $DOCKER_BRIDGE -p udp --dst $DOCKER_BRIDGE_IP --dport $(($PORT + 1)) -j DROP >/dev/null 2>&1 || true
    fi

    kubeadm_run_iptables -t filter -D FORWARD -i $BRIDGE ! -o $BRIDGE -j ACCEPT 2>/dev/null || true
    kubeadm_run_iptables -t filter -D FORWARD -o $BRIDGE -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
    kubeadm_run_iptables -t filter -D FORWARD -i $BRIDGE -o $BRIDGE -j ACCEPT 2>/dev/null || true
    kubeadm_run_iptables -F WEAVE-NPC >/dev/null 2>&1 || true
    kubeadm_run_iptables -t filter -D FORWARD -o $BRIDGE -j WEAVE-NPC 2>/dev/null || true
    kubeadm_run_iptables -t filter -D FORWARD -o $BRIDGE -m state --state NEW -j NFLOG --nflog-group 86 2>/dev/null || true
    kubeadm_run_iptables -t filter -D FORWARD -o $BRIDGE -j DROP 2>/dev/null || true
    kubeadm_run_iptables -X WEAVE-NPC >/dev/null 2>&1 || true

    kubeadm_run_iptables -F WEAVE-EXPOSE >/dev/null 2>&1 || true
    kubeadm_run_iptables -t filter -D FORWARD -o $BRIDGE -j WEAVE-EXPOSE 2>/dev/null || true
    kubeadm_run_iptables -X WEAVE-EXPOSE >/dev/null 2>&1 || true

    kubeadm_run_iptables -t nat -F WEAVE >/dev/null 2>&1 || true
    kubeadm_run_iptables -t nat -D POSTROUTING -j WEAVE >/dev/null 2>&1 || true
    kubeadm_run_iptables -t nat -D POSTROUTING -o $BRIDGE -j ACCEPT >/dev/null 2>&1 || true
    kubeadm_run_iptables -t nat -X WEAVE >/dev/null 2>&1 || true

    for LOCAL_IFNAME in $(ip link show | grep v${CONTAINER_IFNAME}pl | cut -d ' ' -f 2 | tr -d ':') ; do
        ip link del ${LOCAL_IFNAME%@*} >/dev/null 2>&1 || true
    done
}


K8S_DISTRO=
function tasks() {

    DOCKER_VERSION="$(get_docker_version)"

    K8S_DISTRO=kubeadm

    case "$1" in

        reset)
            reset
            ;;
        *)
    esac

    # terminate the script if a task was run
    exit 0
}


# TODO kube-proxy ipvs cleanup
function reset() {
    set +e

    if [ "$FORCE_RESET" != 1 ]; then
        printf "${YELLOW}"
        printf "WARNING: \n"
        printf "\n"
        printf "    The \"reset\" command will attempt to remove kubernetes from this system.\n"
        printf "\n"
        printf "    This command is intended to be used only for \n"
        printf "    increasing iteration speed on development servers. It has the \n"
        printf "    potential to leave your machine in an unrecoverable state. It is \n"
        printf "    not recommended unless you will easily be able to discard this server\n"
        printf "    and provision a new one if something goes wrong.\n${NC}"
        printf "\n"
        printf "Would you like to continue? "

        if ! confirmN; then
            printf "Not resetting\n"
            exit 1
        fi
    fi


    if [ -f /opt/ekco/shutdown.sh ]; then
        bash /opt/ekco/shutdown.sh
    fi

    if commandExists "kubeadm"; then
        printf "Resetting kubeadm\n"
        kubeadm_reset
    fi

    printf "Removing kubernetes packages\n"

    yum remove -y kubernetes-cni kubelet kubectl


    printf "Removing host files\n"
    rm -rf /etc/cni
    rm -rf /etc/kubernetes
    rm -rf /opt/cni
    rm -rf /opt/replicated
    rm -f /usr/bin/kubeadm /usr/bin/kubelet /usr/bin/kubectl /usr/bin/crtctl
    rm -f /usr/local/bin/kustomize*
    rm -rf /var/lib/calico
    rm -rf /var/lib/etcd
    rm -rf /var/lib/kubelet
    rm -rf /var/lib/rook
    rm -rf /var/lib/weave
    rm -rf /var/lib/longhorn
    rm -rf /etc/haproxy

    printf "Reset script completed\n"
}

tasks "$@"
