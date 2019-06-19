module "virtual_router_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes = ["${distinct(concat(module.label.attributes, list("mesh", "virtual", "router")))}"]
  context    = "${module.label.context}"
}

resource "aws_appmesh_virtual_router" "default" {
  count     = "${var.virtual_router_config_count}"
  name      = "${format("%s%s%s", module.virtual_router_label.id, module.virtual_router_label.delimiter, lookup(var.virtual_router_config[count.index], "service_name_suffix", count.index))}"
  mesh_name = "${local.app_mesh_id}"

  spec {
    listener {
      port_mapping {
        port     = "${lookup(var.virtual_router_config[count.index], "port", count.index)}"
        protocol = "${lookup(var.virtual_router_config[count.index], "protocol", count.index)}"
      }
    }
  }
}

## variables.tf
variable "virtual_router_config_count" {
  default = "1"
}

variable "virtual_router_config" {
  type = "list"

  default = [{
    "service_name_suffix" = "service" // If not provided, uses the index number of the count as the suffix
    "port"                = "8080"    // The port used for the port mapping
    "protocol"            = "http"    // The protocol used for the port mapping. Valid values are http and tcp
  }]
}

## outputs.tf
output "virtual_router_config" {
  value = "${var.virtual_router_config}"
}

output "virtual_router_id" {
  value = "${aws_appmesh_virtual_router.default.*.id}"
}

output "virtual_router_arn" {
  value = "${aws_appmesh_virtual_router.default.*.arn}"
}

output "virtual_router_created_date" {
  value = "${aws_appmesh_virtual_router.default.*.created_date}"
}

output "virtual_router_last_updated_date" {
  value = "${aws_appmesh_virtual_router.default.*.last_updated_date}"
}
