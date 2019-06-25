resource "aws_appmesh_virtual_node" "default" {
  count     = "${var.virtual_nodes_count}"
  name      = "${lookup(var.virtual_nodes[count.index], "service_name")}"
  mesh_name = "${local.app_mesh_id}"

  spec {
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

resource "aws_appmesh_virtual_node" "backend" {
  count     = "${var.virtual_backend_nodes_count}"
  name      = "${lookup(var.virtual_backend_nodes[count.index], "service_name")}"
  mesh_name = "${local.app_mesh_id}"

  spec {
    backend {
      ## Backend one
      virtual_service {
        virtual_service_name = "${
        element(
          formatlist(
            "%s.%s", 
            split(",",
            replace(
              lookup(var.virtual_backend_nodes[count.index], "backend_virtual_service_hostname_prefixes")
            , " ", "")), 
            var.ecs_services_domain), 
            0 % length(
              split(",",
                lookup(var.virtual_backend_nodes[count.index], "backend_virtual_service_hostname_prefixes")
              )
            )
        )
            }"
      }
    }

    backend {
      ## Backend two
      virtual_service {
        virtual_service_name = "${
          element(
          formatlist(
            "%s.%s", 
            split(",",
            replace(
              lookup(var.virtual_backend_nodes[count.index], "backend_virtual_service_hostname_prefixes")
            , " ", "")), 
            var.ecs_services_domain), 
            1 % length(
              split(",",
                lookup(var.virtual_backend_nodes[count.index], "backend_virtual_service_hostname_prefixes")
              )
            )
          )
            }"
      }
    }

    listener {
      port_mapping {
        port     = "${lookup(var.virtual_backend_nodes[count.index], "port")}"
        protocol = "${lookup(var.virtual_backend_nodes[count.index], "protocol")}"
      }
    }

    service_discovery {
      dns {
        hostname = "${format("%s.%s", lookup(var.virtual_backend_nodes[count.index], "service_discovery_hostname_prefix"), var.ecs_services_domain)}"
      }
    }
  }

  depends_on = ["aws_appmesh_virtual_service.router", "aws_appmesh_virtual_service.node"]
}

## variables.tf

variable "virtual_nodes_count" {
  default = "0"
}

variable "virtual_backend_nodes_count" {
  default = "0"
}

variable "virtual_nodes" {
  type = "list"

  description = <<EOF
A list of maps that specifies the virtual node details

```
virtual_nodes = [{
    service_discovery_hostname_prefix = "colorteller-red"
    service_name                      = "colorteller-red-vn"
    port                              = "8080"
    protocol                          = "http"
}]
```
EOF

  default = []
}

variable "virtual_backend_nodes" {
  type = "list"

  description = <<EOF
A list of maps that specifies the virtual node details with a backend.
Separate multiple backend virtual service hostname prefixes using a comma.i.e.  "serviceA,serviceB"
This can support up to 2 nodes.

```
virtual_backend_nodes = [{
    backend_virtual_service_hostname_prefixes = "tcpecho,colorteller"
    service_discovery_hostname_prefix         = "colorteller"
    service_name                              = "colorgateway-vn"
    port                                      = "8080"
    protocol                                  = "http"
}]
```
EOF

  default = []
}

## outputs.tf

output "virtual_node_ids" {
  value = "${aws_appmesh_virtual_node.default.*.id}"
}
