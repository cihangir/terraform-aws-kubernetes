resource "template_file" "kube-apiserver" {
  template = "manifests/kube-apiserver.yaml"

  vars = {
    KUBERNETES_VERSION = "${var.kubernetes_version}"
    ETCD_SERVERS = "${join(",", "${formatlist("http://%s:2379", var.etcd_private_ips)}")}"
    SERVICE_CLUSTER_IP_RANGE = "${var.service_cluster_ip_range}"
    SELF_PRIVATE_IP = "172.21.1.129"
  }
}
