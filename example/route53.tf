resource "aws_route53_zone" "this" {
  force_destroy = true
  name          = "${format("%s.%s", module.label.id, var.public_domain_name)}"
}

variable "public_domain_name" {
  default = ""
}
