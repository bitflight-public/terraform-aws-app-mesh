module "virtual_router_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes = ["${distinct(concat(module.label.attributes, list("mesh", "virtual", "node")))}"]
  context    = "${module.label.context}"
}

resource "aws_appmesh_virtual_node" "default" {
  name      = "${lookup(var.virtual_nodes[count.index], "service_name", "service${count.index}")}"
  mesh_name = "${local.app_mesh_id}"

  spec {
    backend {
      virtual_service {
        virtual_service_name = "${format("%s.%s", lookup(var.virtual_nodes[count.index], "backend_virtual_service_name"), var.ecs_services_domain)}"
      }
    }

    listener {
      port_mapping {
        port     = "${lookup(var.virtual_nodes[count.index], "port")}"
        protocol = "${lookup(var.virtual_nodes[count.index], "protocol")}"
      }
    }

    service_discovery {
      dns {
        hostname = "${format("%s.%s", lookup(var.virtual_nodes[count.index], "service_discovery_hostname_prefix"), var.ecs_services_domain)}"
      }
    }
  }
}

## variables.tf

variable "virtual_node_count" {
  default = "1"
}

variable "virtual_nodes" {
  type = "list"

  description = <<EOF
A list of maps that specifies the virtual node details

```
virtual_nodes = [{
        service_discovery_hostname_prefix = "serviceb"
        backend_virtual_service_name_prefix = "servicea"
        service_name = "serviceBv1"
        port = "8080"
        protocol = "http"
}]
```
EOF

  default = [{
    service_discovery_hostname_prefix   = "serviceb"
    backend_virtual_service_name_prefix = "servicea"
    service_name                        = "serviceBv1"
    port                                = "8080"
    protocol                            = "http"
  }]
}

## outputs.tf

