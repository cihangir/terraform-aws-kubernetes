###############################################################
#################### KUBERNETES MASTERS #######################
###############################################################
module "aws_elb_kube_masters" {
  source                      = "github.com/cihangir/terraform-aws//elb"
  name                        = "${var.name}-masters"
  aws_vpc_id                  = "${module.aws_vpc.aws_vpc_vpc_id}"
  aws_subnet_subnet_ids       = "${module.aws_vpc.aws_subnet_subnet_ids}"

  aws_elb_instance_port       = 8080
  aws_elb_instance_protocol   = "tcp"
  aws_elb_port                = 8080
  aws_elb_protocol            = "tcp"
  aws_elb_health_check_target = "HTTP:8080/healthz"
}

module "aws_asg_kube_masters" {
  source                = "github.com/cihangir/terraform-aws//asg"
  name                  = "${var.name}-kube-masters"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
  key_name              = "${module.aws_vpc.aws_key_name}"
  load_balancer_names   = "${module.aws_elb_kube_masters.aws_elb_elb_name}"
  instance_type         = "${var.instance_type_master}"
  ami_id                = "${var.ami_id}"
  desired_cluster_size  = "${var.master_desired_cluster_size}"

  rendered_cloud_init = "${template_file.kube_master_cloud_init_file.rendered}"
  security_groups     = "${aws_security_group.sec_group.id}"
}

# Allow all incoming communication to master elb from vpc
resource "aws_security_group_rule" "allow_all_ingress_within_vpc_to_master_elb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.sec_group.id}"
  security_group_id        = "${module.aws_elb_kube_masters.aws_elb_elb_aws_security_group_sec_group_id}"
}
