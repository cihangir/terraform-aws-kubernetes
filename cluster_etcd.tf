###############################################################
######################## ETCD CLUSTER #########################
###############################################################
module "aws_elb_etcd" {
  source                = "github.com/cihangir/terraform-aws//elb"
  name                  = "${var.name}-etcd"
  aws_vpc_id            = "${module.aws_vpc.aws_vpc_vpc_id}"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"

  aws_elb_instance_port     = 2379
  aws_elb_instance_protocol = "tcp"
  aws_elb_port              = 2379
  aws_elb_protocol          = "tcp"

  aws_elb_instance_port_2     = 2380
  aws_elb_instance_protocol_2 = "tcp"
  aws_elb_port_2              = 2380
  aws_elb_protocol_2          = "tcp"

  aws_elb_health_check_target = "HTTP:2379/health"
}

module "aws_asg_etcd" {
  source                = "github.com/cihangir/terraform-aws//asg"
  name                  = "${var.name}-etcd"
  aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"
  key_name              = "${module.aws_vpc.aws_key_name}"
  load_balancer_names   = "${module.aws_elb_etcd.aws_elb_elb_name}"
  instance_type         = "${var.instance_type_master}"
  ami_id                = "ami-d75bd4bb"
  rendered_cloud_init   = "${template_file.coreos_etcd_cloud_init.rendered}"
  security_groups       = "${module.aws_elb_etcd.aws_elb_elb_aws_security_group_sec_group_id},${module.aws_sg.aws_security_group_sec_group_id}"
}

resource "template_file" "create_etcd_discovery_url" {
  template = "${file("/dev/null")}"

  provisioner "local-exec" {
    command = "curl https://discovery.etcd.io/new?size=${var.master_desired_cluster_size} > ${var.etcd_discovery_url_file}"
  }
}

resource "template_file" "read_etcd_discovery_url_file" {
  depends_on = ["template_file.create_etcd_discovery_url"]

  template = "${file(var.etcd_discovery_url_file)}"
}

resource "template_file" "coreos_etcd_cloud_init" {
  depends_on = ["template_file.read_etcd_discovery_url_file"]

  template = "${file("cloud_init/etcd_coreos.yaml")}"

  vars {
    discovery_url = "${template_file.read_etcd_discovery_url_file.rendered}"
  }
}

# Allow all incoming communication to ETCD elb from the VPC
resource "aws_security_group_rule" "allow_all_ingress_within_vpc_to_etcd_elb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${module.aws_sg.aws_security_group_sec_group_id}"
  security_group_id        = "${module.aws_elb_etcd.aws_elb_elb_aws_security_group_sec_group_id}"
}
