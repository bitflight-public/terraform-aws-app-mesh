resource "aws_appmesh_virtual_router" "default" {
  count     = "${var.virtual_router_config_count}"
  name      = "${lookup(var.virtual_router_config[count.index], "virtual_router_name")}"
  mesh_name = "${local.app_mesh_id}"

  spec {
    listener {
      port_mapping {
        port     = "${lookup(var.virtual_router_config[count.index], "port")}"
        protocol = "${lookup(var.virtual_router_config[count.index], "protocol")}"
      }
    }
  }
}

## variables.tf
variable "virtual_router_config_count" {
  default = "0"
}

variable "virtual_router_config" {
  type = "list"

  default = []

  description = <<EOF
A list of maps that specifies the virtual router details.

```
virtual_router_config = [{
    "virtual_router_name" = "gateway-vr"
    "port"                = "8080"       // The port used for the port mapping
    "protocol"            = "http"       // The protocol used for the port mapping. Valid values are http and tcp
  }]
```
EOF
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
