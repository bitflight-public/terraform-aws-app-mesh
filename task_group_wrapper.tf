locals {
  envoy_env_vars = {
    APPMESH_VIRTUAL_NODE_NAME = "mesh/${local.app_mesh_id}/virtualNode/${aws_appmesh_virtual_node.default.name}"
    ENVOY_LOG_LEVEL           = "${var.envoy_log_level}"
    ENABLE_ENVOY_XRAY_TRACING = "${var.enable_envoy_xray_tracing}"
    XRAY_DAEMON_PORT          = "${var.xray_daemon_port}"
  }
}
