# ECS Draining module will create a lambda function which takes care of instance draining.
module "ecs_draining" {
  source  = "blinkist/airship-ecs-instance-draining/aws"
  version = "0.1.0"
  name    = "web"
}

data "aws_region" "default" {}

locals {
  userdata = <<EOF
#!/bin/bash

cat << LOGGING > /etc/awslogs/awscli.conf
[plugins]
cwlogs = cwlogs
[default]
region = ${data.aws_region.default.name}
LOGGING

cat << LOGGING > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${local.ecs_cluster_name}-/var/log/dmesg
log_stream_name = ${local.ecs_cluster_name}

[/var/log/messages]
file = /var/log/messages
log_group_name = ${local.ecs_cluster_name}-/var/log/messages
log_stream_name = ${local.ecs_cluster_name}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${local.ecs_cluster_name}-/var/log/docker
log_stream_name = ${local.ecs_cluster_name}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = ${local.ecs_cluster_name}-/var/log/ecs/ecs-init.log
log_stream_name = ${local.ecs_cluster_name}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${local.ecs_cluster_name}-/var/log/ecs/ecs-agent.log
log_stream_name = ${local.ecs_cluster_name}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${local.ecs_cluster_name}-/var/log/ecs/audit.log
log_stream_name = ${local.ecs_cluster_name}
datetime_format = %Y-%m-%dT%H:%M:%SZ
LOGGING

yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum install -y hibagent awslogs
service awslogs start
/usr/bin/enable-ec2-spot-hibernation



EOF

  ecs_cluster_name = "${join(module.label.delimiter, list(module.label.id, "web", "cluster"))}"
}

module "ecs_cluster" {
  source = "git::https://github.com/bitflight-public/terraform-aws-airship-ecs-cluster.git"

  # name is re-used as a unique identifier for the creation of different resources
  name = "${local.ecs_cluster_name}"

  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.dynamic_subnets.private_subnet_ids}"]

  cluster_properties {
    # ec2_key_name defines the keypair
    ec2_key_name        = ""
    ec2_custom_userdata = "${local.userdata}"

    # ec2_instance_type defines the instance type
    ec2_instance_type = "c4.large"

    # ec2_asg_min defines the minimum size of the autoscaling group
    ec2_asg_min = "5"

    # ec2_asg_max defines the maximum size of the autoscaling group
    ec2_asg_max = "5"

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
  ecs_instance_scaling_create = false

  # The lambda function which takes care of draining the ecs instance
  ecs_instance_draining_lambda_arn = "" //"${module.ecs_draining.lambda_function_arn}"

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
