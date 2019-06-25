#
# This code was adapted from the `terraform-aws-ecs-container-definition` module from Cloud Posse, LLC on 2018-09-18.
# Available here: https://github.com/cloudposse/terraform-aws-ecs-container-definition
#

locals {
  # null_resource turns "true" into true, adding a temporary string will fix that problem
  safe_search_replace_string = "#keep_true_a_string_hack#"
}

resource "null_resource" "envvars_as_list_of_maps" {
  count = "${length(keys(var.container_envvars))}"

  triggers = "${map(
    "name", "${local.safe_search_replace_string}${element(keys(var.container_envvars), count.index)}",
    "value", "${local.safe_search_replace_string}${element(values(var.container_envvars), count.index)}",
  )}"
}

resource "null_resource" "secrets_as_list_of_maps" {
  count = "${length(keys(var.container_secrets))}"

  triggers = "${map(
    "name", "${local.safe_search_replace_string}${element(keys(var.container_secrets), count.index)}",
    "valueFrom", "${local.safe_search_replace_string}${element(values(var.container_secrets), count.index)}",
  )}"
}

locals {
  port_mappings = {
    with_port = [
      {
        containerPort = "${var.container_port}"
        hostPort      = "${var.host_port}"
        protocol      = "${var.protocol}"
      },
    ]

    without_port = []
  }

  use_port = "${var.container_port == "" ? "without_port" : "with_port" }"

  container_definitions = [{
    name                   = "${var.container_name}"
    image                  = "${var.container_image}"
    memory                 = "${var.container_memory}"
    memoryReservation      = "${var.container_memory_reservation}"
    cpu                    = "${var.container_cpu}"
    essential              = "${var.essential}"
    entryPoint             = "${var.entrypoint}"
    command                = "${var.container_command}"
    workingDirectory       = "${var.working_directory}"
    readonlyRootFilesystem = "${var.readonly_root_filesystem}"
    dockerLabels           = "${local.docker_labels}"

    privileged = "${var.privileged}"

    hostname     = "${var.hostname}"
    environment  = ["${null_resource.envvars_as_list_of_maps.*.triggers}"]
    secrets      = ["${null_resource.secrets_as_list_of_maps.*.triggers}"]
    mountPoints  = ["${var.mountpoints}"]
    portMappings = "${local.port_mappings[local.use_port]}"
    healthCheck  = "${var.healthcheck}"

    logConfiguration = {
      logDriver = "${var.log_driver}"
      options   = "${var.log_options}"
    }
  },
    "${local.with_app_mesh["${var.app_mesh_enabled}"]}",
  ]

  with_app_mesh = {
    "false" = []

    "true" = [{
      "name"              = "xray-daemon"
      "image"             = "amazon/aws-xray-daemon"
      "user"              = "1337"
      "essential"         = true
      "cpu"               = 32
      "memoryReservation" = 256

      "portMappings" = [
        {
          "hostPort"      = 2000
          "containerPort" = 2000
          "protocol"      = "udp"
        },
      ]

      logConfiguration = {
        logDriver = "${var.log_driver}"
        options   = "${var.log_options}"
      }
    },
      {
        "name"      = "envoy"
        "image"     = "${var.envoy_image}"
        "user"      = "1337"
        "essential" = true

        "ulimits" = [
          {
            "name"      = "nofile"
            "hardLimit" = 15000
            "softLimit" = 15000
          },
        ]

        "portMappings" = [
          {
            "containerPort" = 9901
            "hostPort"      = 9901
            "protocol"      = "tcp"
          },
          {
            "containerPort" = 15000
            "hostPort"      = 15000
            "protocol"      = "tcp"
          },
          {
            "containerPort" = 15001
            "hostPort"      = 15001
            "protocol"      = "tcp"
          },
        ]

        "environment" = [
          {
            "name"  = "APPMESH_VIRTUAL_NODE_NAME"
            "value" = "${var.app_mesh_virtual_node_name}"
          },
          {
            "name"  = "ENVOY_LOG_LEVEL"
            "value" = "${var.envoy_log_level}"
          },
          {
            "name"  = "APPMESH_XDS_ENDPOINT"
            "value" = "${var.appmesh_xds_endpoint}"
          },
          {
            "name"  = "ENABLE_ENVOY_XRAY_TRACING"
            "value" = "1"
          },
          {
            "name"  = "ENABLE_ENVOY_STATS_TAGS"
            "value" = "1"
          },
        ]

        logConfiguration = {
          logDriver = "${var.log_driver}"
          options   = "${var.log_options}"
        }

        "healthCheck" = {
          "command" = [
            "CMD-SHELL",
            "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE",
          ]

          "interval" = 5
          "timeout"  = 2
          "retries"  = 3
        }
      },
    ]
  }
}
