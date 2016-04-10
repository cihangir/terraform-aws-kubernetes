resource "template_file" "kube-apiserver" {
  template = "file(manifests/kube-apiserver.yaml)"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    ETCD_SERVERS             = "http://${module.aws_elb_etcd.aws_elb_elb_dns_name}:2379"
    SERVICE_CLUSTER_IP_RANGE = "${var.service_cluster_ip_range}"
  }
}

resource "template_file" "kube-controller-manager" {
  template = "file(manifests/kube-controller-manager.yaml)"

  vars = {
    KUBERNETES_VERSION = "${var.kubernetes_version}"
    CLUSTER_NAME       = "${var.cluster_name}"
  }
}

resource "template_file" "kube-podmaster" {
  template = "file(manifests/kube-podmaster.yaml)"

  vars = {
    ETCD_SERVERS    = "http://${module.aws_elb_etcd.aws_elb_elb_dns_name}:2379"
  }
}

resource "template_file" "kube-proxy" {
  template = "file(manifests/kube-proxy.yaml)"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    KUBE_API_SERVER_ENDPOINT = "${module.aws_elb_kube_masters.aws_elb_elb_dns_name}"
  }
}
