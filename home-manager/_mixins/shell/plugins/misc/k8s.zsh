# kubernetes triage script
# function triage() {
#   namespace=${1:-default}

#   config=https://raw.githubusercontent.com/jacbart/dotfiles/main/config/triage/triage.yaml
#   kubectl apply -n $namespace -f $config
#   msg="waiting for pod"
#   waittime=0
#   echo -n "$msg ${waittime}s"
#   while [[ $(kubectl get -n $namespace pod/triage -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
#     sleep 1
#     ((waittime++))
#     printf "\r$msg ${waittime}s"
#   done
#   printf "\n"

#   kubectl exec -n $namespace -ti triage -- /bin/zsh
#   kubectl delete -n $namespace -f $config
# }


function triage() {
  namespace=${1:-default}

  config=https://raw.githubusercontent.com/taybart/dotfiles/main/triage.yaml
  kubectl apply -n $namespace -f $config
  msg="waiting for pod"
  waittime=0
  echo -n "$msg ${waittime}s"
  while [[ $(kubectl get -n $namespace pod/triage -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    sleep 1
    ((waittime++))
    printf "\r$msg ${waittime}s"
  done
  printf "\n"

  kubectl exec -n $namespace -ti triage -- /bin/zsh
  kubectl delete -n $namespace -f $config
}

# kubernetes context management function
function kcxt() {
  if [[ -z $1 ]]; then
      kubectl config get-contexts | awk '/^[^*|CURRENT]/{print $1} /^\*/{print "\033[1;32m" $2 "\033[0m "}'
  elif [[ $# -ge 1 ]]; then
    case "$1" in
      "ns" | "namespace" | "-ns" | "-namespace")
        kubectl config set-context --current --namespace="$2"
      ;;
      *)
        kubectl config use-context "$1"
      ;;
    esac
  fi
}

# kubernetes remove evicted pods
function kc-remove-evicted() {
  kubectl get pod --all-namespaces -o json | \
  jq  '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | "kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | \
  xargs -n 1 bash -c
}

# kubernetes remove a namespace that is stuck in terminating state
function namespace-force-remove() {
  if [[ -z $1 ]]; then
    echo "choose namespace"
  else
    NAMESPACE=$1
    kubectl get namespaces $NAMESPACE -o json | jq '.spec.finalizers=[]' > /tmp/ns.json
    kubectl proxy &
    PROXY_PID=$!
    curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/ns.json http://127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
    sleep 2s
    kill $PROXY_PID
  fi
}

# kubernetes enter pod shell
function kc-shell() {
  if [[ $# != 2 ]]; then
    echo "usage: kc-shell <Pod Name> <Namespace>"
  else
    PODNAME=$1
    NAMESPACE=$2
    kubectl exec -ti $PODNAME -n $NAMESPACE -- sh
  fi
}

function localkube() {
  # install k3d
  if ! type "k3d" &> /dev/null; then
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
  fi
  # localkube setup and removal
  if [[ "$1" == "up" ]]; then
    k3d cluster create localkube \
      --registry-create localkube-registry:0.0.0.0:5000 \
      --port 8080:80@loadbalancer \
      --port 8443:443@loadbalancer
  elif [[ "$1" == "down" ]]; then
    k3d cluster delete localkube
  fi
}