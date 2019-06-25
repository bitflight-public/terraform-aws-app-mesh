variable "virtual_route_http_config_count" {
  default = "0"
}

variable "virtual_route_http_config" {
  type    = "list"
  default = []

  description = <<EOF
```hcl
  virtual_route_http_config = [{
    "virtual_router_name"          = "gateway-vr"
    "route_name"                   = "colorteller-route"
    "match_prefix"                 = "/"
    "weighted_target_virtual_node" = "colorteller-red-vn"
    "weighted_target_weight"       = "10"
  }]
```
EOF
}

resource "aws_appmesh_route" "default" {
  count               = "${var.virtual_route_http_config_count}"
  name                = "${lookup(var.virtual_route_http_config[count.index], "route_name")}"
  mesh_name           = "${local.app_mesh_id}"
  virtual_router_name = "${lookup(var.virtual_route_http_config[count.index], "virtual_router_name")}"

  spec {
    http_route {
      match {
        prefix = "${lookup(var.virtual_route_http_config[count.index], "match_prefix", "/")}"
      }

      action {
        weighted_target {
          virtual_node = "${lookup(var.virtual_route_http_config[count.index], "weighted_target_virtual_node", "/")}"
          weight       = "${lookup(var.virtual_route_http_config[count.index], "weighted_target_weight", "/")}"
        }
      }
    }
  }

  depends_on = ["aws_appmesh_virtual_service.router", "aws_appmesh_virtual_service.node"]
}
