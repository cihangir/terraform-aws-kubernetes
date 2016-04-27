KUBERNETES_VERSION=${KUBERNETES_VERSION}

KUBE_API_SERVER_ENDPOINT=${KUBE_API_SERVER_ENDPOINT}

KUBE_KUBELET_OPTS="--api_servers=${KUBE_API_SERVER_ENDPOINT} \
  --register-node=true \
  --allow-privileged=true \
  --config=/etc/kubernetes/manifests \
  --hostname-override=$private_ipv4 \
  --cluster-dns=${CLUSTER_DNS_ENDPOINT} \
  --cluster-domain=${CLUSTER_DOMAIN} \
  --tls-cert-file=/etc/kubernetes/ssl/worker.pem \
  --tls-private-key-file=/etc/kubernetes/ssl/worker-key.pem \
  --v=3 \
  --cadvisor-port=0 \
  --logtostderr=true \
  --cloud-provider=aws"
