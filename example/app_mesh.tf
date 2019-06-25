variable "colorteller_port" {
  default = "9080"
}

variable "tcpecho_port" {
  default = "2701"
}

module "app_mesh" {
  source              = "../"
  context             = "${module.label.context}"
  ecs_services_domain = "${aws_service_discovery_private_dns_namespace.default.name}"

  virtual_nodes_count = "4"

  virtual_nodes = [
    {
      service_discovery_hostname_prefix = "colorteller-blue"
      service_name                      = "colorteller-blue-vn"
      port                              = "${var.colorteller_port}"
      protocol                          = "http"
    },
    {
      service_discovery_hostname_prefix = "colorteller-red"
      service_name                      = "colorteller-red-vn"
      port                              = "${var.colorteller_port}"
      protocol                          = "http"
    },
    {
      service_discovery_hostname_prefix = "colorteller-white"
      service_name                      = "colorteller-white-vn"
      port                              = "${var.colorteller_port}"
      protocol                          = "http"
    },
    {
      service_discovery_hostname_prefix = "tcpecho"
      service_name                      = "tcpecho-vn"
      port                              = "${var.tcpecho_port}"
      protocol                          = "http"
    },
  ]

  virtual_router_config_count = "1"

  virtual_router_config = [
    {
      "service_name_suffix" = "colorteller-vr"          // If not provided, uses the index number of the count as the suffix
      "port"                = "${var.colorteller_port}" // The port used for the port mapping
      "protocol"            = "http"                    // The protocol used for the port mapping. Valid values are http and tcp
    },
  ]

  virtual_service_router_config_count = "1"

  virtual_service_router_config = [
    {
      "virtual_service_name_prefix"  = "colorteller"
      "provider_virtual_router_name" = "colorteller-vr"
    },
  ]

  virtual_service_node_config_count = "1"

  virtual_service_node_config = [
    {
      "virtual_service_name_prefix"  = "tcpecho"
      "provider_virtual_router_name" = "tcpecho-vn"
    },
  ]

  virtual_backend_nodes_count = "1"

  virtual_backend_nodes = [{
    backend_virtual_service_hostname_prefixes = "tcpecho,colorteller"
    service_discovery_hostname_prefix         = "colorteller"
    service_name                              = "colorgateway-vn"
    port                                      = "8080"
    protocol                                  = "http"
  }]
}

output "mesh_id" {
  value = "${module.app_mesh.mesh_id}"
}
