resource "aws_lb" "this" {
  name                             = "${module.label.id}"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = ["${aws_security_group.lb_sg.id}"]
  subnets                          = ["${module.dynamic_subnets.public_subnet_ids}"]
  idle_timeout                     = 30
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = "${module.label.tags}"
}

output "alb_dns_endpoint" {
  value = "${aws_lb.this.dns_name}"
}
