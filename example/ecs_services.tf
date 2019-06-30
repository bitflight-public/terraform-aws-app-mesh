module "label_colorteller_red" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes  = ["red"]
  label_order = ["name", "attributes"]
  context     = "${module.label.context}"
}

module "colorteller_service_red" {
  source = "./modules/ecs_service"

  create           = "true"
  app_mesh_enabled = "true"

  # Container name 
  container_name                                                    = "app"
  context                                                           = "${module.label_colorteller_red.context}"
  container_definition_json                                         = "${module.container_definition_colorteller_red.json}"
  live_task_lookup_type                                             = "lambda"
  service_discovery_enabled                                         = true
  service_discovery_properties_namespace_id                         = "${aws_service_discovery_private_dns_namespace.default.id}"
  service_discovery_properties_dns_ttl                              = "60"
  service_discovery_properties_dns_type                             = "A"
  service_discovery_properties_routing_policy                       = "MULTIVALUE"
  service_discovery_properties_healthcheck_custom_failure_threshold = "1"
  awsvpc_enabled                                                    = true
  awsvpc_subnets                                                    = ["${module.dynamic_subnets.private_subnet_ids}"]
  awsvpc_security_group_ids                                         = ["${aws_security_group.ecs_task_sg.id}"]

  # ecs_cluster_id is the cluster to which the ECS Service will be added.
  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"

  # Region of the ECS Cluster
  region = "${data.aws_region.current.name}"

  # image_url defines the docker image location
  bootstrap_container_image = "${module.build_docker_images.repository_urls["colorteller"]}"

  # cpu defines the needed cpu for the container
  container_cpu = "256"

  # container_memory  defines the hard memory limit of the container
  container_memory = "128"

  # port defines the needed port of the container
  container_port                                = "${var.colorteller_port}"
  task_proxy_configuration_properties_app_ports = "${var.colorteller_port}"

  # scheduling_strategy defaults to REPLICA
  scheduling_strategy = "REPLICA"

  # Spread tasks over ECS Cluster based on AZ, Instance-id, memory
  with_placement_strategy = false

  # load_balancing_type is either "none", "network","application"
  load_balancing_type                           = "none"
  load_balancing_properties_lb_arn              = "${aws_lb.this.arn}"
  load_balancing_properties_route53_record_type = "NONE"
  load_balancing_properties_route53_zone_id     = "ABC"

  # deployment_controller_type sets the deployment type
  # ECS for Rolling update, and CODE_DEPLOY for Blue/Green deployment via CodeDeploy
  deployment_controller_type = "ECS"

  ## capacity_properties map defines the capacity properties of the service
  force_bootstrap_container_image = "false"
}

module "label_colorteller_blue" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes  = ["blue"]
  label_order = ["name", "attributes"]
  context     = "${module.label.context}"
}

module "colorteller_service_blue" {
  source = "./modules/ecs_service"

  create           = "true"
  app_mesh_enabled = "true"

  # Container name 
  container_name                                                    = "app"
  context                                                           = "${module.label_colorteller_blue.context}"
  container_definition_json                                         = "${module.container_definition_colorteller_blue.json}"
  live_task_lookup_type                                             = "lambda"
  service_discovery_enabled                                         = true
  service_discovery_properties_namespace_id                         = "${aws_service_discovery_private_dns_namespace.default.id}"
  service_discovery_properties_dns_ttl                              = "60"
  service_discovery_properties_dns_type                             = "A"
  service_discovery_properties_routing_policy                       = "MULTIVALUE"
  service_discovery_properties_healthcheck_custom_failure_threshold = "1"
  awsvpc_enabled                                                    = true
  awsvpc_subnets                                                    = ["${module.dynamic_subnets.private_subnet_ids}"]
  awsvpc_security_group_ids                                         = ["${aws_security_group.ecs_task_sg.id}"]

  # ecs_cluster_id is the cluster to which the ECS Service will be added.
  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"

  # Region of the ECS Cluster
  region = "${data.aws_region.current.name}"

  # image_url defines the docker image location
  bootstrap_container_image = "${module.build_docker_images.repository_urls["colorteller"]}"

  # cpu defines the needed cpu for the container
  container_cpu = "256"

  # container_memory  defines the hard memory limit of the container
  container_memory = "128"

  # port defines the needed port of the container
  container_port                                = "${var.colorteller_port}"
  task_proxy_configuration_properties_app_ports = "${var.colorteller_port}"

  # scheduling_strategy defaults to REPLICA
  scheduling_strategy = "REPLICA"

  # Spread tasks over ECS Cluster based on AZ, Instance-id, memory
  with_placement_strategy = false

  # load_balancing_type is either "none", "network","application"
  load_balancing_type                           = "none"
  load_balancing_properties_lb_arn              = "${aws_lb.this.arn}"
  load_balancing_properties_route53_record_type = "NONE"
  load_balancing_properties_route53_zone_id     = "ABC"

  # deployment_controller_type sets the deployment type
  # ECS for Rolling update, and CODE_DEPLOY for Blue/Green deployment via CodeDeploy
  deployment_controller_type = "ECS"

  ## capacity_properties map defines the capacity properties of the service
  force_bootstrap_container_image = "false"
}

module "label_colorteller_white" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes  = ["white"]
  label_order = ["name"]                                                                      //, "attributes"]
  context     = "${module.label.context}"
}

module "colorteller_service_white" {
  source = "./modules/ecs_service"

  create           = "true"
  app_mesh_enabled = "true"

  # Container name 
  container_name                                                    = "app"
  context                                                           = "${module.label_colorteller_white.context}"
  container_definition_json                                         = "${module.container_definition_colorteller_white.json}"
  live_task_lookup_type                                             = "lambda"
  service_discovery_enabled                                         = true
  service_discovery_properties_namespace_id                         = "${aws_service_discovery_private_dns_namespace.default.id}"
  service_discovery_properties_dns_ttl                              = "60"
  service_discovery_properties_dns_type                             = "A"
  service_discovery_properties_routing_policy                       = "MULTIVALUE"
  service_discovery_properties_healthcheck_custom_failure_threshold = "1"
  awsvpc_enabled                                                    = true
  awsvpc_subnets                                                    = ["${module.dynamic_subnets.private_subnet_ids}"]
  awsvpc_security_group_ids                                         = ["${aws_security_group.ecs_task_sg.id}"]

  # ecs_cluster_id is the cluster to which the ECS Service will be added.
  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"

  # Region of the ECS Cluster
  region = "${data.aws_region.current.name}"

  # image_url defines the docker image location
  bootstrap_container_image = "${module.build_docker_images.repository_urls["colorteller"]}"

  # cpu defines the needed cpu for the container
  container_cpu = "256"

  # container_memory  defines the hard memory limit of the container
  container_memory = "128"

  # port defines the needed port of the container
  container_port                                = "${var.colorteller_port}"
  task_proxy_configuration_properties_app_ports = "${var.colorteller_port}"

  # scheduling_strategy defaults to REPLICA
  scheduling_strategy = "REPLICA"

  # Spread tasks over ECS Cluster based on AZ, Instance-id, memory
  with_placement_strategy = false

  # load_balancing_type is either "none", "network","application"
  load_balancing_type                           = "none"
  load_balancing_properties_lb_arn              = "${aws_lb.this.arn}"
  load_balancing_properties_route53_record_type = "NONE"
  load_balancing_properties_route53_zone_id     = "ABC"

  # deployment_controller_type sets the deployment type
  # ECS for Rolling update, and CODE_DEPLOY for Blue/Green deployment via CodeDeploy
  deployment_controller_type = "ECS"

  ## capacity_properties map defines the capacity properties of the service
  force_bootstrap_container_image = "false"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "I'm not crying, you're crying. ${module.label_gateway.id}"
      status_code  = "200"
    }
  }
}

module "label_gateway" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  name        = "colorgateway"
  label_order = ["name"]
  context     = "${module.label.context}"
}

module "gateway_service" {
  source = "./modules/ecs_service"

  create           = "true"
  app_mesh_enabled = "true"

  context                                                           = "${module.label_gateway.context}"
  container_definition_json                                         = "${module.container_definition_gateway.json}"
  service_discovery_enabled                                         = true
  service_discovery_properties_namespace_id                         = "${aws_service_discovery_private_dns_namespace.default.id}"
  service_discovery_properties_dns_ttl                              = "60"
  service_discovery_properties_dns_type                             = "A"
  service_discovery_properties_routing_policy                       = "MULTIVALUE"
  service_discovery_properties_healthcheck_custom_failure_threshold = "2"
  awsvpc_enabled                                                    = true
  awsvpc_subnets                                                    = ["${module.dynamic_subnets.private_subnet_ids}"]
  awsvpc_security_group_ids                                         = ["${aws_security_group.ecs_task_sg.id}"]
  capacity_properties_desired_min_capacity                          = "1"
  capacity_properties_desired_capacity                              = "1"

  # ecs_cluster_id is the cluster to which the ECS Service will be added.
  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"

  # Region of the ECS Cluster
  region = "${data.aws_region.current.name}"

  # image_url defines the docker image location
  bootstrap_container_image = "${module.build_docker_images.repository_urls["gateway"]}"

  # Container name 
  container_name = "app"

  # cpu defines the needed cpu for the container
  container_cpu = "256"

  # container_memory  defines the hard memory limit of the container
  container_memory = "128"

  # port defines the needed port of the container
  container_port                                = "${var.colorteller_port}"
  task_proxy_configuration_properties_app_ports = "${var.colorteller_port}"

  # scheduling_strategy defaults to REPLICA
  scheduling_strategy = "REPLICA"

  # Spread tasks over ECS Cluster based on AZ, Instance-id, memory
  with_placement_strategy = false

  # load_balancing_type is either "none", "network","application"
  load_balancing_type = "application"

  ## load_balancing_properties map defines the map for services hooked to a load balancer
  load_balancing_properties_route53_zone_id           = "${aws_route53_zone.this.zone_id}"
  load_balancing_properties_route53_custom_name       = "app"
  load_balancing_properties_lb_vpc_id                 = "${module.vpc.vpc_id}"
  load_balancing_properties_target_group_port         = "${var.colorteller_port}"
  load_balancing_properties_deregistration_delay      = 120
  load_balancing_properties_lb_arn                    = "${aws_lb.this.arn}"
  load_balancing_properties_lb_listener_arn           = "${aws_lb_listener.this.arn}"
  load_balancing_properties_cognito_auth_enabled      = false
  load_balancing_properties_route53_record_type       = "NONE"
  load_balancing_properties_custom_listen_hosts       = ["${aws_lb.this.dns_name}"]
  load_balancing_properties_custom_listen_hosts_count = "1"
  load_balancing_properties_https_enabled             = false

  # deployment_controller_type sets the deployment type
  # ECS for Rolling update, and CODE_DEPLOY for Blue/Green deployment via CodeDeploy
  deployment_controller_type = "ECS"

  ## capacity_properties map defines the capacity properties of the service
  force_bootstrap_container_image = "false"
}

module "label_tcpecho" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  name        = "tcpecho"
  label_order = ["name"]
  context     = "${module.label.context}"
}

module "tcpecho_service" {
  source = "./modules/ecs_service"

  create           = "true"
  app_mesh_enabled = "false"

  # Container name 
  container_name                                                    = "tcpecho"
  context                                                           = "${module.label_tcpecho.context}"
  container_definition_json                                         = "${module.container_definition_tcpecho.json}"
  service_discovery_enabled                                         = true
  service_discovery_properties_namespace_id                         = "${aws_service_discovery_private_dns_namespace.default.id}"
  service_discovery_properties_dns_ttl                              = "60"
  service_discovery_properties_dns_type                             = "A"
  service_discovery_properties_routing_policy                       = "MULTIVALUE"
  service_discovery_properties_healthcheck_custom_failure_threshold = "1"
  awsvpc_enabled                                                    = true
  awsvpc_subnets                                                    = ["${module.dynamic_subnets.private_subnet_ids}"]
  awsvpc_security_group_ids                                         = ["${aws_security_group.ecs_task_sg.id}"]

  # ecs_cluster_id is the cluster to which the ECS Service will be added.
  ecs_cluster_id = "${module.ecs_cluster.cluster_id}"

  # Region of the ECS Cluster
  region = "${data.aws_region.current.name}"

  # image_url defines the docker image location
  bootstrap_container_image = "${module.build_docker_images.repository_urls["colorteller"]}"

  # cpu defines the needed cpu for the container
  container_cpu = "256"

  # container_memory  defines the hard memory limit of the container
  container_memory = "128"

  # port defines the needed port of the container
  container_port = "${var.tcpecho_port}"

  # scheduling_strategy defaults to REPLICA
  scheduling_strategy = "REPLICA"

  # Spread tasks over ECS Cluster based on AZ, Instance-id, memory
  with_placement_strategy = false

  # load_balancing_type is either "none", "network","application"
  load_balancing_type = "none"

  #   ## load_balancing_properties map defines the map for services hooked to a load balancer
  #   load_balancing_properties_route53_zone_id      = "${aws_route53_zone.this.zone_id}"
  #   load_balancing_properties_route53_custom_name  = "service-web"
  #   load_balancing_properties_lb_vpc_id            = "${data.aws_vpc.selected.id}"
  #   load_balancing_properties_target_group_port    = "${var.echo_port}"
  #   load_balancing_properties_nlb_listener_port    = "${var.echo_port}"
  #   load_balancing_properties_deregistration_delay = 0
  #   load_balancing_properties_lb_arn               = "${aws_lb.this.arn}"
  #   load_balancing_properties_cognito_auth_enabled = false
  #   load_balancing_properties_route53_record_type  = "ALIAS"
  load_balancing_properties_lb_arn = "${aws_lb.this.arn}"

  load_balancing_properties_route53_record_type = "NONE"

  load_balancing_properties_route53_zone_id = "ABC"

  # deployment_controller_type sets the deployment type
  # ECS for Rolling update, and CODE_DEPLOY for Blue/Green deployment via CodeDeploy
  deployment_controller_type = "ECS"

  ## capacity_properties map defines the capacity properties of the service
  force_bootstrap_container_image = "false"
}
