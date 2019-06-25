variable "STAGE" {
  default = ""
}

module "container_definition_gateway" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["gateway"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/${module.app_mesh.virtual_node_ids[0]}"

  container_port = "9080"
  host_port      = "9080"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT           = "9080"
    COLOR_TELLER_ENDPOINT = "${format("%s.%s:%s", "colorteller", aws_service_discovery_private_dns_namespace.default.name, "9080")}"
    TCP_ECHO_ENDPOINT     = "${format("%s.%s:%s", "tcpecho", aws_service_discovery_private_dns_namespace.default.name, "2701")}"
    STAGE                 = "${var.STAGE}"
  }
}

module "container_definition_colorteller_red" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-red-vn}"

  container_port = "9080"
  host_port      = "9080"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT           = "9080"
    COLOR_TELLER_ENDPOINT = "${format("%s.%s:%s", "colorteller", aws_service_discovery_private_dns_namespace.default.name, "9080")}"
    TCP_ECHO_ENDPOINT     = "${format("%s.%s:%s", "tcpecho", aws_service_discovery_private_dns_namespace.default.name, "2701")}"
    STAGE                 = "${var.STAGE}"
  }
}
