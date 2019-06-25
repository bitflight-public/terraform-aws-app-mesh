resource "aws_route53_zone" "demo" {
  name = "${format("%s.local", module.label.id)}"
}
