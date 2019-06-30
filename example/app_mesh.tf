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
      protocol                          = "tcp"
    },
  ]

  virtual_router_config_count = "1"

  virtual_router_config = [
    {
      "virtual_router_name" = "colorteller-vr"
      "port"                = "${var.colorteller_port}"
      "protocol"            = "http"                    // The protocol used for the port mapping. Valid values are http and tcp
    },
  ]

  ## The virtual route http config is set up as a list of maps
  ## of lists because in tf 0.11 maps cant contain mixed types.
  virtual_route_http_virtual_router_name = "colorteller-vr"

  virtual_route_http_match_prefix = "/"

  virtual_route_http_weighted_targets = [
    {
      "virtual_node" = "colorteller-red-vn"
      "weight"       = "10"
    },
    {
      "virtual_node" = "colorteller-blue-vn"
      "weight"       = "10"
    },
    {
      "virtual_node" = "colorteller-white-vn"
      "weight"       = "10"
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
      "virtual_service_name_prefix" = "tcpecho"
      "provider_virtual_node_name"  = "tcpecho-vn"
    },
  ]

  virtual_backend_nodes_count = "1"

  virtual_backend_nodes = [{
    backend_virtual_service_hostname_prefixes = "tcpecho,colorteller"
    service_discovery_hostname_prefix         = "colorgateway"
    service_name                              = "colorgateway-vn"
    port                                      = "${var.colorteller_port}"
    protocol                                  = "http"
  }]
}

output "mesh_id" {
  value = "${module.app_mesh.mesh_id}"
}
