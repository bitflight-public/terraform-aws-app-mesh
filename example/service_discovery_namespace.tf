variable "service_discovery_private_namespace_name" {
  default = "appmesh.local"
}

variable "service_discovery_private_namespace_description" {
  default = ""
}

resource "aws_service_discovery_private_dns_namespace" "default" {
  name        = "${var.service_discovery_private_namespace_name}"
  description = "${var.service_discovery_private_namespace_description}"
  vpc         = "${module.vpc.vpc_id}"
}
