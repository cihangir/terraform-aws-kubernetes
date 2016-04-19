KUBERNETES_VERSION=${KUBERNETES_VERSION}

KUBE_API_SERVER_ENDPOINT=${KUBE_API_SERVER_ENDPOINT}

KUBE_KUBELET_OPTS="--api_servers=http://127.0.0.1:8080 \
  --register-node=false \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=$private_ipv4 \
  --cluster-dns=${CLUSTER_DNS_ENDPOINT} \
  --cluster_domain=${CLUSTER_DOMAIN} \
  --cadvisor-port=0 \
  --logtostderr=true \
  --v=2"
