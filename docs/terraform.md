## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tag_map | Additional tags for appending to each tag map | map | `<map>` | no |
| attributes | Any extra attributes for naming these resources | list | `<list>` | no |
| aws_appmesh_envoy_image | After you create your service mesh, virtual nodes, virtual routers, routes, and virtual services, you add the following App Mesh Envoy container image to the ECS task or Kubernetes pod represented by your App Mesh virtual nodes | string | `111345817488.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.9.1.0-prod` | no |
| context | The context output from an external label module to pass to the label modules within this module | map | `<map>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| ecs_services_domain | DNS namespace used by services e.g. default.svc.cluster.local | string | - | yes |
| egress_filter_type | The egress filter type. By default, the type is DROP_ALL. Valid values are ALLOW_ALL and DROP_ALL | string | `DROP_ALL` | no |
| enable_envoy_xray_tracing | - | string | `true` | no |
| environment | The environment name if not using stage | string | `` | no |
| envoy_log_level | This can be trace, debug, info, warning, error, critical, off | string | `info` | no |
| existing_mesh_id | To provide an existing app mesh id for the module to use, instead of creating a new one. | string | `` | no |
| label_order | The naming order of the id output and Name tag | list | `<list>` | no |
| load_balancer_path | A path on the public load balancer that this service   should be connected to. Use * to send all load balancer   traffic to this service. | string | `*` | no |
| mesh_name_override | To provide a custom name to the aws_appmesh_mesh resource, by default it is named by the label module. | string | `` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | string | `` | no |
| regex_replace_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed | string | `/[^a-zA-Z0-9-]/` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | `` | no |
| tags | Additional tags to apply to all resources that use this label module | map | `<map>` | no |
| virtual_backend_nodes | A list of maps that specifies the virtual node details with a backend. Separate multiple backend virtual service hostname prefixes using a comma.i.e.  "serviceA,serviceB" This can support up to 2 nodes.<br><br>``` virtual_backend_nodes = [{     backend_virtual_service_hostname_prefixes = "tcpecho,colorteller"     service_discovery_hostname_prefix         = "colorgateway"     service_name                              = "colorgateway-vn"     port                                      = "9080"     protocol                                  = "http" }] ``` | list | `<list>` | no |
| virtual_backend_nodes_count | - | string | `0` | no |
| virtual_nodes | A list of maps that specifies the virtual node details<br><br>``` virtual_nodes = [{     service_discovery_hostname_prefix = "colorteller-red"     service_name                      = "colorteller-red-vn"     port                              = "8080"     protocol                          = "http" }] ``` | list | `<list>` | no |
| virtual_nodes_count | - | string | `0` | no |
| virtual_route_http_match_prefix | - | string | `/` | no |
| virtual_route_http_virtual_router_name | - | string | `` | no |
| virtual_route_http_weighted_targets | - | list | `<list>` | no |
| virtual_router_config | A list of maps that specifies the virtual router details.<br><br>``` virtual_router_config = [{     "virtual_router_name" = "gateway-vr"     "port"                = "8080"       // The port used for the port mapping     "protocol"            = "http"       // The protocol used for the port mapping. Valid values are http and tcp   }] ``` | list | `<list>` | no |
| virtual_router_config_count | # variables.tf | string | `0` | no |
| virtual_service_node_config | ```hcl   virtual_service_node_config = [{     "virtual_service_name_prefix"   = "colorteller" // .appmesh.local     "provider_virtual_node_name"    = "colorteller-red-vn"   }] ``` | list | `<list>` | no |
| virtual_service_node_config_count | - | string | `0` | no |
| virtual_service_router_config | ```hcl   virtual_service_router_config = [{     "virtual_service_name_prefix"           = "colorteller" // .appmesh.local     "provider_virtual_router_name"          = "colorteller-vr"   }] ``` | list | `<list>` | no |
| virtual_service_router_config_count | # variables.tf | string | `0` | no |
| xray_daemon_port | - | string | `2000` | no |

## Outputs

| Name | Description |
|------|-------------|
| mesh_arn | - |
| mesh_created_date | - |
| mesh_id | # outputs.tf |
| mesh_last_updated_date | - |
| virtual_node_ids | - |
| virtual_router_arn | - |
| virtual_router_config | # outputs.tf |
| virtual_router_created_date | - |
| virtual_router_id | - |
| virtual_router_last_updated_date | - |

