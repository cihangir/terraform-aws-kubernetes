resource "template_file" "kube-apiserver" {
  template = "manifests/kube-apiserver.yaml"

  vars = {
    KUBERNETES_VERSION = "${var.kubernetes_version}"
    ETCD_SERVERS = "${join(",", "${formatlist("http://%s:2379", module.kube_etcd.aws_instance.etcd.*.private_ip)}")}"
    cluster_cidr = "${var.cluster_cidr}"
    service_cluster_ip_range = "${var.service_cluster_ip_range}"
    advertise_address = "172.21.1.129"
  }
}
