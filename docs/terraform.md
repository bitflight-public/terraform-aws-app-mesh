## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tag_map | Additional tags for appending to each tag map | map | `<map>` | no |
| attributes | Any extra attributes for naming these resources | list | `<list>` | no |
| context | The context output from an external label module to pass to the label modules within this module | map | `<map>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| ecs_services_domain | DNS namespace used by services e.g. default.svc.cluster.local | string | - | yes |
| egress_filter_type | The egress filter type. By default, the type is DROP_ALL. Valid values are ALLOW_ALL and DROP_ALL | string | `DROP_ALL` | no |
| environment | The environment name if not using stage | string | `` | no |
| label_order | The naming order of the id output and Name tag | list | `<list>` | no |
| load_balancer_path | A path on the public load balancer that this service   should be connected to. Use * to send all load balancer   traffic to this service. | string | `*` | no |
| mesh_name_override | To provide a custom name to the aws_appmesh_mesh resource, by default it is named by the label module. | string | `` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | string | `` | no |
| regex_replace_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed | string | `/[^a-zA-Z0-9-]/` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | `` | no |
| tags | Additional tags to apply to all resources that use this label module | map | `<map>` | no |
| task_definition_arns | - | list | `<list>` | no |
| virtual_node_count | - | string | `1` | no |
| virtual_nodes | A list of maps that specifies the virtual node details<br><br>``` virtual_nodes = [{         service_discovery_hostname_prefix = "serviceb"         backend_virtual_service_name_prefix = "servicea"         service_name = "serviceBv1"         port = "8080"         protocol = "http" }] ``` | list | `<list>` | no |
| virtual_router_config | - | list | `<list>` | no |
| virtual_router_config_count | # variables.tf | string | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| mesh_arn | - |
| mesh_created_date | - |
| mesh_id | # outputs.tf |
| mesh_last_updated_date | - |
| virtual_router_arn | - |
| virtual_router_config | # outputs.tf |
| virtual_router_created_date | - |
| virtual_router_id | - |
| virtual_router_last_updated_date | - |

