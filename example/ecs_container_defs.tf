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

module "container_definition_tcpecho" {
  source = "./modules/ecs_container_definition"

  container_name   = "tcpecho"
  container_image  = "cjimti/go-echo"
  app_mesh_enabled = "false"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "tcpecho"
  }

  container_port = "${var.tcpecho_port}"
  host_port      = "${var.tcpecho_port}"
  protocol       = "tcp"
  essential      = "true"

  container_envvars = {
    TCP_PORT  = "${var.tcpecho_port}"
    NODE_NAME = "mesh/${module.app_mesh.mesh_id}/virtualNode/tcpecho-vn"
  }
}

module "container_definition_gateway" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["gateway"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorgateway-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "gateway"
  }

  container_port = "${var.colorteller_port}"
  host_port      = "${var.colorteller_port}"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT           = "${var.colorteller_port}"
    COLOR_TELLER_ENDPOINT = "${format("%s.%s:%s", "colorteller", aws_service_discovery_private_dns_namespace.default.name, var.colorteller_port)}"
    TCP_ECHO_ENDPOINT     = "${format("%s.%s:%s", "tcpecho", aws_service_discovery_private_dns_namespace.default.name, var.tcpecho_port)}"
    STAGE                 = "${var.STAGE}"
  }
}

module "container_definition_colorteller_red" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-red-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "colorteller-red"
  }

  container_port = "${var.colorteller_port}"
  host_port      = "${var.colorteller_port}"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT = "${var.colorteller_port}"
    COLOR       = "red"
    STAGE       = "${var.STAGE}"
  }
}

module "container_definition_colorteller_blue" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-blue-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "colorteller-blue"
  }

  container_port = "${var.colorteller_port}"
  host_port      = "${var.colorteller_port}"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT = "${var.colorteller_port}"
    COLOR       = "blue"
    STAGE       = "${var.STAGE}"
  }
}

module "container_definition_colorteller_white" {
  source = "./modules/ecs_container_definition"

  container_name             = "app"
  container_image            = "${module.build_docker_images.repository_urls["colorteller"]}"
  app_mesh_enabled           = "true"
  app_mesh_virtual_node_name = "mesh/${module.app_mesh.mesh_id}/virtualNode/colorteller-white-vn"

  log_options = {
    "awslogs-region"        = "${data.aws_region.current.name}"
    "awslogs-group"         = "${aws_cloudwatch_log_group.app.name}"
    "awslogs-stream-prefix" = "colorteller-white"
  }

  container_port = "${var.colorteller_port}"
  host_port      = "${var.colorteller_port}"
  protocol       = "tcp"

  container_envvars = {
    SERVER_PORT = "${var.colorteller_port}"
    COLOR       = "white"
    STAGE       = "${var.STAGE}"
  }
}
