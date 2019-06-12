variable "ecs_services_domain" {
  description = "DNS namespace used by services e.g. default.svc.cluster.local"
}

# variable "load_balancer_path" {
#   default = "*"

#   description = <<EOF
#   A path on the public load balancer that this service
#   should be connected to. Use * to send all load balancer
#   traffic to this service.
# EOF
# }