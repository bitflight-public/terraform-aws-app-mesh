variable "virtual_route_http_virtual_router_name" {
  type    = "string"
  default = ""
}

variable "virtual_route_http_match_prefix" {
  type    = "string"
  default = "/"
}

variable "virtual_route_http_weighted_targets" {
  type    = "list"
  default = []
}

resource "aws_appmesh_route" "default" {
  count               = "${var.virtual_route_http_virtual_router_name != "" ? 1 : 0}"
  name                = "${format("%s%sroute", var.virtual_route_http_virtual_router_name, module.label.delimiter)}"
  mesh_name           = "${local.app_mesh_id}"
  virtual_router_name = "${var.virtual_route_http_virtual_router_name}"

  spec {
    http_route {
      match {
        prefix = "${var.virtual_route_http_match_prefix}"
      }

      action {
        weighted_target = ["${var.virtual_route_http_weighted_targets}"]
      }
    }
  }

  depends_on = ["aws_appmesh_virtual_service.router", "aws_appmesh_virtual_service.node"]
}
