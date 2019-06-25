# name of the ecs_service
variable "name" {}

# create
variable "create" {
  default = true
}

# cluster name
variable "cluster_name" {}

# is awsvpc enabled ?
variable "awsvpc_enabled" {
  default = false
}

# is fargate enabled ?
variable "fargate_enabled" {
  default = false
}

# container_definitions set the json with the container definitions
variable "container_definitions" {}

# cpu is set in case Fargate is used
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "cpu" {}

# memory is set in case Fargate is used
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "memory" {}

# ecs_taskrole_arn sets the arn of the ECS Task role
variable "ecs_taskrole_arn" {}

# ecs_task_execution_role_arn sets the execution role arn, needed for FARGATE
variable "ecs_task_execution_role_arn" {}

# AWS Region
variable "region" {}

# launch_type sets the launch_type, either EC2 or FARGATE
variable "launch_type" {}

# A Docker volume to add to the task
variable "docker_volume" {
  type    = "map"
  default = {}

  # {
  # # these properties are supported as a 'flattened' version of the docker volume configuration:
  # # https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#docker_volume_configuration
  #     name = "bla",
  #     scope == "shared",
  #     autoprovision = true,
  #     driver = "foo"
  # # these properties are NOT supported, as they are nested maps in the resource's configuration
  # #   driver_opts = NA
  # #   labels = NA
  # }
}

# list of host paths to add as volumes to the task
variable "host_path_volumes" {
  type    = "list"
  default = []

  # {
  #     name = "service-storage",
  #     host_path = "/foo"
  # },
}

# list of mount points to add to every container in the task
variable "mountpoints" {
  type    = "list"
  default = []

  # {
  #     source_volume = "service-storage",
  #     container_path = "/foo",
  #     read_only = "false"
  # },
}

variable "task_proxy_configuration_type" {
  default = "APPMESH"
}

variable "task_proxy_configuration_container_name" {
  default = "envoy"
}

variable "task_proxy_configuration_properties_app_ports" {
  default = "8080"
}

variable "task_proxy_configuration_properties_egress_ignored_ips" {
  default = "169.254.170.2,169.254.169.254"
}

variable "task_proxy_configuration_properties_ignored_uid" {
  default = "1337"
}

variable "task_proxy_configuration_properties_proxy_egress_port" {
  default = "15001"
}

variable "task_proxy_configuration_properties_proxy_ingress_port" {
  default = "15000"
}

variable "enable_app_mesh" {
  description = "If not false, enable the aws app mesh proxy"
  default     = "false"
}
