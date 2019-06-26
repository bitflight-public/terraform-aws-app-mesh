variable "STAGE" {
  default = ""
}

variable "log_retention_in_days" {
  default = "7"
}

variable "cloudwatch_kms_key" {
  default = ""
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "${local.ecs_cluster_name}/${module.label.id}"
  retention_in_days = "${var.log_retention_in_days}"
  kms_key_id        = "${var.cloudwatch_kms_key}"
}

module "container_definition_gateway" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["gateway"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/gateway-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "app"
  }

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

  container_name             = "colorteller"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-red-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "colorteller-red"
  }

  container_port = "9080"
  host_port      = "9080"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT           = "9080"
    COLOR_TELLER_ENDPOINT = "${format("%s.%s:%s", "colorteller", aws_service_discovery_private_dns_namespace.default.name, "9080")}"
    TCP_ECHO_ENDPOINT     = "${format("%s.%s:%s", "tcpecho", aws_service_discovery_private_dns_namespace.default.name, "2701")}"
    STAGE                 = "${var.STAGE}"
  }

  log_options = {
    "awslogs-region" = "us-west-2"

    "awslogs-group" = "default"

    "awslogs-stream-prefix" = "default"
  }
}

module "container_definition_colorteller_blue" {
  source = "./modules/ecs_container_definition"

  container_name             = "colorteller"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-blue-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "colorteller-blue"
  }

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

module "container_definition_colorteller_white" {
  source = "./modules/ecs_container_definition"

  container_name             = "colorteller"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-white-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "colorteller-white"
  }

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
