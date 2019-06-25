# module "virtual_service_label" {
#   source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
#   attributes = ["${distinct(concat(module.label.attributes, list("mesh", "virtual", "service")))}"]
#   context    = "${module.label.context}"
# }

resource "aws_appmesh_virtual_service" "node" {
  count     = "${var.virtual_service_node_config_count}"
  name      = "${format("%s.%s", lookup(var.virtual_service_node_config[count.index], "virtual_service_name_prefix"), var.ecs_services_domain)}"
  mesh_name = "${local.app_mesh_id}"

  spec {
    provider {
      virtual_node {
        virtual_node_name = "${lookup(var.virtual_service_node_config[count.index], "provider_virtual_node_name")}"
      }
    }
  }

  depends_on = ["aws_appmesh_virtual_node.default"]
}

resource "aws_appmesh_virtual_service" "router" {
  count     = "${var.virtual_service_router_config_count}"
  name      = "${format("%s.%s", lookup(var.virtual_service_router_config[count.index], "virtual_service_name_prefix"), var.ecs_services_domain)}"
  mesh_name = "${local.app_mesh_id}"

  spec {
    provider {
      virtual_router {
        virtual_router_name = "${lookup(var.virtual_service_router_config[count.index], "provider_virtual_router_name")}"
      }
    }
  }

  depends_on = ["aws_appmesh_virtual_router.default"]
}

## variables.tf
variable "virtual_service_router_config_count" {
  default = "0"
}

variable "virtual_service_node_config_count" {
  default = "0"
}

variable "virtual_service_node_config" {
  type = "list"

  default = []

  description = <<EOF
```hcl
  virtual_service_node_config = [{
    "virtual_service_name_prefix"   = "colorteller" // .appmesh.local
    "provider_virtual_node_name"    = "colorteller-red-vn"
  }]
```
EOF
}

variable "virtual_service_router_config" {
  type = "list"

  default = []

  description = <<EOF
```hcl
  virtual_service_router_config = [{
    "virtual_service_name_prefix"           = "colorteller" // .appmesh.local
    "provider_virtual_router_name"   = "colorteller-vr"
  }]
```
EOF
}

## outputs.tf

