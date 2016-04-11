resource "template_file" "kube-apiserver" {
  template = "${file("manifests/kube-apiserver.yaml.tpl")}"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    ETCD_SERVERS             = "http://${module.aws_elb_etcd.aws_elb_elb_dns_name}:2379"
    SERVICE_CLUSTER_IP_RANGE = "${var.service_cluster_ip_range}"
  }
}

resource "template_file" "kube-controller-manager" {
  template = "${file("manifests/kube-controller-manager.yaml.tpl")}"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    KUBE_API_SERVER_ENDPOINT = "http://${module.aws_elb_kube_masters.aws_elb_elb_dns_name}:8080"
  }
}

resource "template_file" "kube-podmaster" {
  template = "${file("manifests/kube-podmaster.yaml.tpl")}"

  vars = {
    ETCD_SERVERS = "http://${module.aws_elb_etcd.aws_elb_elb_dns_name}:2379"
  }
}

resource "template_file" "kube-proxy" {
  template = "${file("manifests/kube-proxy.yaml.tpl")}"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    KUBE_API_SERVER_ENDPOINT = "http://${module.aws_elb_kube_masters.aws_elb_elb_dns_name}:8080"
  }
}

resource "template_file" "kube-scheduler" {
  template = "${file("manifests/kube-scheduler.yaml.tpl")}"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    KUBE_API_SERVER_ENDPOINT = "http://${module.aws_elb_kube_masters.aws_elb_elb_dns_name}:8080"
  }
}

resource "template_file" "kube-kubelet-master-service" {
  template = "${file("units/kube-kubelet-master.service.tpl")}"
}

resource "template_file" "kube-kubelet-node-service" {
  template = "${file("units/kube-kubelet-node.service.tpl")}"
}

resource "template_file" "kube_master_cloud_init_file" {
  template = "${file("coreos_kube_masters_cloud_init.yaml.tpl")}"

  vars = {
    ETCD_ELB_DNS_NAME                        = "${module.aws_elb_kube_masters.aws_elb_elb_dns_name}"

    KUBE_APISERVER_TEMPLATE_CONTENT          = "${template_file.kube-apiserver.rendered}"
    KUBE_CONTROLLER_MANAGER_TEMPLATE_CONTENT = "${template_file.kube-controller-manager.rendered}"
    KUBE_PODMASTER_TEMPLATE_CONTENT          = "${template_file.kube-podmaster.rendered}"
    KUBE_PROXY_TEMPLATE_CONTENT              = "${template_file.kube-proxy.rendered}"
    KUBE_SCHEDULER_TEMPLATE_CONTENT          = "${template_file.kube-scheduler.rendered}"

    KUBE_KUBELET_MASTER_TEMPLATE_CONTENT     = "${template_file.kube-kubelet-master-service.rendered}"
  }
}
