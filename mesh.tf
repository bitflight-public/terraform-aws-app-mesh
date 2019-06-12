module "mesh_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes = ["${distinct(concat(module.label.attributes, list("mesh")))}"]
  context    = "${module.label.context}"
}

resource "aws_appmesh_mesh" "default" {
  count = "${var.existing_mesh_id == "" ? 1 : 0}"
  name  = "${var.mesh_name_override == "" ? module.label.id : var.mesh_name_override}"

  spec {
    egress_filter {
      type = "${var.egress_filter_type}"
    }
  }
}

## variables.tf
variable "existing_mesh_id" {
  description = "To provide an existing app mesh id for the module to use, instead of creating a new one."
  default     = ""
}
variable "mesh_name_override" {
  description = "To provide a custom name to the aws_appmesh_mesh resource, by default it is named by the label module."
  default     = ""
}

variable "egress_filter_type" {
  default     = "DROP_ALL"
  description = "The egress filter type. By default, the type is DROP_ALL. Valid values are ALLOW_ALL and DROP_ALL"
}

locals {
  app_mesh_id = "${var.existing_mesh_id == "" ? join("", aws_appmesh_mesh.default.*.id) : var.existing_mesh_id}"
}

## outputs.tf
output "mesh_id" {
  value = "${local.app_mesh_id}"
}

output "mesh_arn" {
  value = "${join("", aws_appmesh_mesh.default.*.arn)}"
}

output "mesh_created_date" {
  value = "${join("", aws_appmesh_mesh.default.*.created_date)}"
}

output "mesh_last_updated_date" {
  value = "${join("", aws_appmesh_mesh.default.*.last_updated_date)}"
}
