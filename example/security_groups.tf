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

resource "aws_security_group_rule" "allow_internet_to_lb" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb_sg.id}"
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
