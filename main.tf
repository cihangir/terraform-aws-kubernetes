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

variable "ami_id" {
  default = "ami-cd0886a1"
}

variable "master_desired_cluster_size" {
  default = "3"
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
  default = "10.3.0.0/24"
}

variable "cluster_dns_endpoint" {
  default = "10.3.0.1"
}


variable "kubernetes_pods_ip_range" {
    default = "10.2.0.0/16"
}
variable "kubernetes_version" {
  default = "1.2.2"
}

variable "cluster_name" {
  default = "kubernetes_cluster"
}

variable "cluster_domain" {
  default = "cluster.local"
}

variable "kubernetes_skydns_replica_count" {
  default = "1"
}

variable "kubernetes_flannel_backend" {
    default = "vxlan"
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
