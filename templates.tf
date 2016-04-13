#
# Manifest Templates
#
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

#
# Add-on Templates
#
resource "template_file" "skydns-rc" {
  template = "${file("addons/kube-skydns-rc.yaml.tpl")}"

  vars = {
    DNS_REPLICAS   = "${var.kubernetes_skydns_replica_count}"
    DNS_DOMAIN     = "${var.cluster_domain}"                  # same value with CLUSTER_DOMAIN, just here to keep compatibility with upstream
    CLUSTER_DOMAIN = "${var.cluster_domain}"
  }
}

resource "template_file" "skydns-svc" {
  template = "${file("addons/kube-skydns-svc.yaml.tpl")}"

  vars = {
    CLUSTER_DNS_ENDPOINT = "${var.cluster_dns_endpoint}"
    DNS_SERVER_IP        = "${var.cluster_dns_endpoint}" # again, for upstream compatibility
  }
}

#
# Unit Templates
#
resource "template_file" "kube-kubelet-master-service" {
  template = "${file("units/kube-kubelet-master.service.tpl")}"
}

resource "template_file" "kube-kubelet-node-service" {
  template = "${file("units/kube-kubelet-node.service.tpl")}"
}

resource "template_file" "instance-env-file" {
  template = "${file("units/instance.env.tpl")}"

  vars = {
    INSTANCE_ROLE = "master"
  }
}

resource "template_file" "kubernetes-env-file" {
  template = "${file("units/kubernetes.env.tpl")}"

  vars = {
    KUBERNETES_VERSION       = "${var.kubernetes_version}"
    KUBE_API_SERVER_ENDPOINT = "http://${module.aws_elb_kube_masters.aws_elb_elb_dns_name}:8080"
    CLUSTER_DNS_ENDPOINT     = "${var.cluster_dns_endpoint}"
    CLUSTER_DOMAIN           = "${var.cluster_domain}"
  }
}

#
# Main Templates
#
resource "template_file" "kube_master_cloud_init_file" {
  template = "${file("coreos_kube_masters_cloud_init.yaml.tpl")}"

  vars = {
    ETCD_ELB_DNS_NAME = "${module.aws_elb_etcd.aws_elb_elb_dns_name}"

    KUBE_KUBELET_MASTER_TEMPLATE_CONTENT = "${template_file.kube-kubelet-master-service.rendered}"

    KUBE_APISERVER_TEMPLATE_CONTENT          = "${base64encode(gzip(template_file.kube-apiserver.rendered))}"
    KUBE_CONTROLLER_MANAGER_TEMPLATE_CONTENT = "${base64encode(gzip(template_file.kube-controller-manager.rendered))}"
    KUBE_PODMASTER_TEMPLATE_CONTENT          = "${base64encode(gzip(template_file.kube-podmaster.rendered))}"
    KUBE_PROXY_TEMPLATE_CONTENT              = "${base64encode(gzip(template_file.kube-proxy.rendered))}"
    KUBE_SCHEDULER_TEMPLATE_CONTENT          = "${base64encode(gzip(template_file.kube-scheduler.rendered))}"
    KUBE_SKYDNS_RC_TEMPLATE_CONTENT          = "${base64encode(gzip(template_file.skydns-rc.rendered))}"
    KUBE_SKYDNS_SVC_TEMPLATE_CONTENT         = "${base64encode(gzip(template_file.skydns-svc.rendered))}"

    KUBERNETES_ENV_FILE_TEMPLATE_CONTENT = "${base64encode(gzip(template_file.kubernetes-env-file.rendered))}"
    INSTANCE_ENV_FILE_TEMPLATE_CONTENT   = "${base64encode(gzip(template_file.instance-env-file.rendered))}"
  }
}