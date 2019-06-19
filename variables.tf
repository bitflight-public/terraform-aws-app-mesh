variable "ecs_services_domain" {
  description = "DNS namespace used by services e.g. default.svc.cluster.local"
}

variable "load_balancer_path" {
  default = "*"
  description = <<EOF
  A path on the public load balancer that this service
  should be connected to. Use * to send all load balancer
  traffic to this service.
EOF
}

## https://docs.aws.amazon.com/app-mesh/latest/userguide/envoy.html
## https://github.com/aws/aws-app-mesh-roadmap/issues/10
variable "aws_appmesh_envoy_image" {
  description = "After you create your service mesh, virtual nodes, virtual routers, routes, and virtual services, you add the following App Mesh Envoy container image to the ECS task or Kubernetes pod represented by your App Mesh virtual nodes"
  default = "111345817488.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.9.1.0-prod"
}
variable "envoy_log_level" {
  default = "info"
  description = "This can be trace, debug, info, warning, error, critical, off"
}
variable "enable_envoy_xray_tracing" {
  default = true
}
variable "xray_daemon_port" {
  default = "2000"
}
