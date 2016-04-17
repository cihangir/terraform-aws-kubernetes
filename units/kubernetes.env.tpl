KUBERNETES_VERSION=${KUBERNETES_VERSION}

KUBE_API_SERVER_ENDPOINT=${KUBE_API_SERVER_ENDPOINT}

KUBE_KUBELET_NODE_OPTS="--api_servers=${KUBE_API_SERVER_ENDPOINT} \
  --register-node=true \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=$(cat /etc/private_ipv4) \
  --cluster-dns=${CLUSTER_DNS_ENDPOINT} \
  --cluster-domain=${CLUSTER_DOMAIN} \
  --kubeconfig=/etc/kubernetes/worker-kubeconfig.yaml \
  --tls-cert-file=/etc/kubernetes/ssl/worker.pem \
  --tls-private-key-file=/etc/kubernetes/ssl/worker-key.pem \
  --v=2 \
  --cadvisor-port=0 \
  --cloud-provider=aws"

KUBE_KUBELET_MASTER_OPTS="--api_servers=http://127.0.0.1:8080 \
  --register-node=false \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=$(cat /etc/private_ipv4) \
  --cluster-dns=${CLUSTER_DNS_ENDPOINT} \
  --cluster_domain=${CLUSTER_DOMAIN} \
  --cadvisor-port=0 \
  --logtostderr=true \
  --v=2"
