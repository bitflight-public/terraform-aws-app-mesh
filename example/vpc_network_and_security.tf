resource "aws_security_group" "lb_sg" {
  name        = "${join(module.label.delimiter, list(module.label.id, "lb", "sg"))}"
  description = "Allow all inbound traffic to http and https"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${module.label.tags}"
}

resource "aws_security_group" "ecs_instance_sg" {
  name        = "${join(module.label.delimiter, list(module.label.id, "inst", "sg"))}"
  description = "Allow traffic to instance"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${module.label.tags}"
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "${join(module.label.delimiter, list(module.label.id, "task", "sg"))}"
  description = "Allow all inbound traffic from mesh and lb to task"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${module.label.tags}"
}

resource "aws_security_group_rule" "allow_lb_to_instance" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "65535"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb_sg.id}"
  security_group_id        = "${aws_security_group.ecs_instance_sg.id}"
}

resource "aws_security_group_rule" "allow_egress_from_instance" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ecs_instance_sg.id}"
}

resource "aws_security_group_rule" "allow_egress_from_task" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ecs_task_sg.id}"
}

resource "aws_security_group_rule" "allow_egress_from_lb" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb_sg.id}"
}

resource "aws_security_group_rule" "allow_lb_to_task" {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "65535"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb_sg.id}"
  security_group_id        = "${aws_security_group.ecs_task_sg.id}"
}

resource "aws_security_group" "admin_sg" {
  name        = "${join(module.label.delimiter, list(module.label.id, "instance", "admin", "sg"))}"
  description = "Allow all inbound traffic from whitelisted IPs"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = "${module.label.tags}"
}

### This looks up the IP of where this terraform is being run from, 
### and adds it to the white list, so you can access the service.
data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "allow_user" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "65535"
  protocol          = "tcp"
  cidr_blocks       = ["${format("%s/%s",trimspace(data.http.icanhazip.body), "32")}"]
  security_group_id = "${aws_security_group.admin_sg.id}"
}

# ECS Draining module will create a lambda function which takes care of instance draining.
module "ecs_draining" {
  source  = "blinkist/airship-ecs-instance-draining/aws"
  version = "0.1.0"
  name    = "web"
}

module "ecs_cluster" {
  source  = "blinkist/airship-ecs-cluster/aws"
  version = "0.5.1"

  # name is re-used as a unique identifier for the creation of different resources
  name = "${join(module.label.delimiter, list(module.label.id, "web", "cluster"))}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.dynamic_subnets.private_subnet_ids}"]

  cluster_properties {
    # ec2_key_name defines the keypair
    ec2_key_name = ""

    # ec2_instance_type defines the instance type
    ec2_instance_type = "t3.small"

    # ec2_asg_min defines the minimum size of the autoscaling group
    ec2_asg_min = "3"

    # ec2_asg_max defines the maximum size of the autoscaling group
    ec2_asg_max = "3"

    # ec2_disk_size defines the size in GB of the non-root volume of the EC2 Instance
    ec2_disk_size = "100"

    # ec2_disk_type defines the disktype of that EBS Volume
    ec2_disk_type       = "gp2"
    ec2_disk_encryption = "true"

    # block_metadata_service blocks the aws metadata service from the ECS Tasks true / false, this is preferred security wise
    block_metadata_service = false

    # efs_enabled sets if EFS should be mounted
    efs_enabled = false
  }

  # vpc_security_group_ids defines the security groups for the ec2 instances.
  vpc_security_group_ids = ["${aws_security_group.ecs_instance_sg.id}", "${aws_security_group.admin_sg.id}"]

  # ecs_instance_scaling_create defines if we set autscaling for the autoscaling group
  # NB! NB! A draining lambda ARN needs to be defined !!
  ecs_instance_scaling_create = true

  # The lambda function which takes care of draining the ecs instance
  ecs_instance_draining_lambda_arn = "${module.ecs_draining.lambda_function_arn}"

  # ecs_instance_scaling_properties defines how the ECS Cluster scales up / down
  ecs_instance_scaling_properties = [
    {
      type               = "MemoryReservation"
      direction          = "up"
      evaluation_periods = 2
      observation_period = "300"
      statistic          = "Average"
      threshold          = "50"
      cooldown           = "900"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "1"
    },
    {
      type               = "MemoryReservation"
      direction          = "down"
      evaluation_periods = 4
      observation_period = "300"
      statistic          = "Average"
      threshold          = "10"
      cooldown           = "300"
      adjustment_type    = "ChangeInCapacity"
      scaling_adjustment = "-1"
    },
  ]

  tags = "${module.label.tags}"
}

module "dynamic_subnets" {
  source                  = "../../terraform-aws-dynamic-subnets"
  context                 = "${module.label.context}"
  region                  = "${data.aws_region.current.name}"
  availability_zones      = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"] // Optional list of AZ's to restrict it to
  vpc_id                  = "${module.vpc.vpc_id}"
  igw_id                  = "${module.vpc.igw_id}"
  public_subnet_count     = "2"                                                                      // Two public zones for the load balancers
  private_subnet_count    = "3"                                                                      // Four private zones for the 
  map_public_ip_on_launch = "true"

  ## You can use nat_gateway_enabled or nat_instance_enabled
  ## It creates one nat instance per public subnet.
  ## So if you want to exclude the public subnet by setting the public_subnet_count to 0
  ## You will neet to use the nat_gateway_enabled option.
  nat_instance_enabled = "false"

  nat_gateway_enabled = "true"
}

## VPC module doesn't have the latest version of null_label 
## module integrated with it at the time of this example being 
## written so no context variable here.
module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.4.1"
  namespace  = "${module.label.namespace}"
  stage      = "${module.label.environment}"
  name       = "${module.label.name}"
  attributes = ["${module.label.attributes}"]
  delimiter  = "${module.label.delimiter}"
  tags       = "${module.label.tags}"
  cidr_block = "${var.vpc_cidr}"
}

data "aws_region" "current" {}



variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

provider "aws" {
  version                     = "~> 2.12"
  region                      = "us-east-2"
  skip_requesting_account_id  = true        # this can be tricky
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}
