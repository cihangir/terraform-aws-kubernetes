resource "template_file" "kube-apiserver" {
  template = "manifests/kube-apiserver.yaml"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    ETCD_SERVERS             = "${join(",", "${formatlist("http://%s:2379", var.etcd_private_ips)}")}"
    SERVICE_CLUSTER_IP_RANGE = "${var.service_cluster_ip_range}"
    SELF_PRIVATE_IP          = "192.168.127.131"
  }
}

resource "template_file" "kube-controller-manager" {
  template = "manifests/kube-controller-manager.yaml"

  vars = {
    KUBERNETES_VERSION = "${var.kubernetes_version}"
    CLUSTER_NAME       = "${var.cluster_name}"
  }
}

resource "template_file" "kube-podmaster" {
  template = "manifests/kube-podmaster.yaml"

  vars = {
    ETCD_SERVERS    = "${join(",", "${formatlist("http://%s:2379", var.etcd_private_ips)}")}"
    SELF_PRIVATE_IP = "192.168.127.131"
  }
}

resource "template_file" "kube-proxy" {
  template = "manifests/kube-proxy.yaml"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    KUBE_API_SERVER_ENDPOINT = "${var.kube_api_server_endpoint}"
  }
}