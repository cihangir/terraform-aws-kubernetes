##############################################################
#################### KUBERNETES NODES ########################
##############################################################
module "aws_elb_kube_nodes" {
  source                = "github.com/cihangir/terraform-aws//elb"
  name                  = "${var.name}-nodes"
  aws_vpc_id            = "${module.aws_vpc.aws_vpc_vpc_id}"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"

  aws_elb_instance_port       = 10255
  aws_elb_instance_protocol   = "tcp"
  aws_elb_port                = 10255
  aws_elb_protocol            = "tcp"
  aws_elb_health_check_target = "HTTP:10255/healthz"
}


module "aws_asg_kube_nodes" {
  source                = "github.com/cihangir/terraform-aws//asg"
  name                  = "${var.name}-kube-nodes"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
  key_name              = "${module.aws_vpc.aws_key_name}"
  load_balancer_names   = "${module.aws_elb_kube_nodes.aws_elb_elb_name}"
  instance_type         = "${var.instance_type_master}"
  ami_id                = "${var.ami_id}"
  desired_cluster_size  = "${var.master_desired_cluster_size}"

  rendered_cloud_init = "${template_file.kube_node_cloud_init_file.rendered}"
  security_groups     = "${aws_security_group.sec_group.id}"
}
