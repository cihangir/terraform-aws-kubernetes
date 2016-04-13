###############################################################


##################### KUBERNETES NODES ########################


###############################################################


# module "aws_elb_kube_nodes" {


#   source                = "github.com/cihangir/terraform-aws//elb"


#   name                  = "${var.name}"


#   aws_vpc_id            = "${module.aws_vpc.aws_vpc_vpc_id}"


#   aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"


# }


#


# module "aws_asg_kube_nodes" {


#   source                = "github.com/cihangir/terraform-aws//asg"


#   name                  = "${var.name}-kube-nodes"


#   aws_subnet_subnet_ids = "${module.aws_vpc.aws_subnet_subnet_ids}"


#   key_name              = "${module.aws_vpc.aws_key_name}"


#   load_balancer_names   = "${module.aws_elb_kube_nodes.aws_elb_elb_name}"


#   instance_type         = "${var.instance_type_master}"


#   ami_id                = "ami-c40784a8"


# }
