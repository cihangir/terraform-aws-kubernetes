variable "access_key" {}

variable "secret_key" {}
provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
  max_retries = 7
}

variable "region" {
  description = "AWS Region."
  default     = "sa-east-1"
}

variable "name" {}

variable "etcd_discovery_url_file" {
  default = "etcd_discovery_url.txt"
}

variable "master_desired_cluster_size" {
  default = "2"
}

variable "instance_type_master" {
  default = "m3.xlarge"
}

variable "instance_type_node" {
  default = "m3.xlarge"
}

variable "instance_type_etcd" {
  default = "m3.xlarge"
}

variable "service_cluster_ip_range" {
  default = "10.0.0.0/24"
}

variable "kubernetes_version" {
  default = "1.2.2"
}

variable "cluster_name" {
  default = "kubernetes_cluster"
}

###############################################################
############## master vpc to create resources in ##############
###############################################################
module "aws_vpc" {
  source = "github.com/cihangir/terraform-aws//vpc"
  name   = "${var.name}"
}

###############################################################
##### master security group that allows all communication #####
###############################################################
module "aws_sg" {
  source     = "github.com/cihangir/terraform-aws//secgroups"
  name       = "${var.name}"
  aws_vpc_id = "${module.aws_vpc.aws_vpc_vpc_id}"
}

###############################################################
######################## ETCD CLUSTER #########################
###############################################################
module "aws_elb_etcd" {
  source                      = "github.com/cihangir/terraform-aws//elb"
  name                        = "${var.name}-etcd"
  aws_vpc_id                  = "${module.aws_vpc.aws_vpc_vpc_id}"
  aws_subnet_subnet_ids       = "${module.aws_vpc.aws_subnet_subnet_ids}"
  aws_elb_instance_port       = 2379
  aws_elb_instance_protocol   = "tcp"
  aws_elb_port                = 2379
  aws_elb_protocol            = "tcp"
  aws_elb_health_check_target = "HTTP:2379/health"
}

module "aws_asg_etcd" {
  source                = "github.com/cihangir/terraform-aws//asg"
  name                  = "${var.name}-etcd"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
  key_name              = "${module.aws_vpc.aws_key_name}"
  load_balancer_names   = "${module.aws_elb_etcd.aws_elb_elb_name}"
  instance_type         = "${var.instance_type_master}"
  ami_id                = "ami-c40784a8"
}

###############################################################
#################### KUBERNETES MASTERS #######################
###############################################################
module "aws_elb_kube_masters" {
  source                = "github.com/cihangir/terraform-aws//elb"
  name                  = "${var.name}"
  aws_vpc_id            = "${module.aws_vpc.aws_vpc_vpc_id}"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
}

module "aws_asg_kube_masters" {
  source                = "github.com/cihangir/terraform-aws//asg"
  name                  = "${var.name}-kube-masters"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
  key_name              = "${module.aws_vpc.aws_key_name}"
  load_balancer_names   = "${module.aws_elb_kube_masters.aws_elb_elb_name}"
  instance_type         = "${var.instance_type_master}"
  ami_id                = "ami-c40784a8"
  desired_cluster_size  = "${var.master_desired_cluster_size}"
}

resource "template_file" "etcd_discovery_url" {
  template = "file(/dev/null)"
  provisioner "local-exec" {
    command = "curl https://discovery.etcd.io/new?size=${var.master_desired_cluster_size} > ${var.etcd_discovery_url_file}"
  }
}


###############################################################
##################### KUBERNETES NODES ########################
###############################################################
module "aws_elb_kube_nodes" {
  source                = "github.com/cihangir/terraform-aws//elb"
  name                  = "${var.name}"
  aws_vpc_id            = "${module.aws_vpc.aws_vpc_vpc_id}"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
}

module "aws_asg_kube_nodes" {
  source                = "github.com/cihangir/terraform-aws//asg"
  name                  = "${var.name}-kube-nodes"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
  key_name              = "${module.aws_vpc.aws_key_name}"
  load_balancer_names   = "${module.aws_elb_kube_nodes.aws_elb_elb_name}"
  instance_type         = "${var.instance_type_master}"
  ami_id                = "ami-c40784a8"
}
