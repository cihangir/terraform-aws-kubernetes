##############################################################
#################### KUBERNETES NODES ########################
##############################################################
module "aws_elb_kube_nodes" {
  source                = "github.com/cihangir/terraform-aws//elb"
  name                  = "${var.name}-nodes"
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
  ami_id                = "ami-5fb63833"
  desired_cluster_size  = "${var.master_desired_cluster_size}"

  rendered_cloud_init = "${template_file.kube_master_cloud_init_file.rendered}"
  security_groups     = "${module.aws_elb_kube_nodes.aws_elb_elb_aws_security_group_sec_group_id},${module.aws_sg.aws_security_group_sec_group_id}"
}

# Allow all incoming communication to ETCD elb from kube nodes
resource "aws_security_group_rule" "allow_all_ingress_from_kube_nodes_to_etcd_elb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${module.aws_elb_kube_nodes.aws_elb_elb_aws_security_group_sec_group_id}"
  security_group_id        = "${module.aws_elb_etcd.aws_elb_elb_aws_security_group_sec_group_id}"
}
