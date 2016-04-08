variable "access_key" {}

variable "secret_key" {}

variable "name" {}

variable "instance_type_master" {
  default = "m3.xlarge"
}

variable "instance_type_node" {
  default = "m3.xlarge"
}

variable "instance_type_etcd" {
  default = "m3.xlarge"
}

module "kube_master" {
  source        = "github.com/cihangir/terraform-aws"
  instance_type = "${var.instance_type_master}"
  access_key    = "${var.access_key}"
  secret_key    = "${var.secret_key}"
  name          = "${var.name}-master"
  ami_id        = "ami-74dcfc17"
}

module "kube_nodes" {
  source        = "github.com/cihangir/terraform-aws"
  instance_type = "${var.instance_type_node}"
  access_key    = "${var.access_key}"
  secret_key    = "${var.secret_key}"
  name          = "${var.name}-node"
  ami_id        = "ami-74dcfc17"
}

module "kube_etcd" {
  source        = "github.com/cihangir/terraform-aws"
  instance_type = "${var.instance_type_etcd}"
  access_key    = "${var.access_key}"
  secret_key    = "${var.secret_key}"
  name          = "${var.name}-etcd"
  ami_id        = "ami-74dcfc17"
}
