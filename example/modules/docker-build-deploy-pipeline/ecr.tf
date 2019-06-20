variable "ecr_repo_names" {
  type    = "list"
  default = []
}

locals {
  principals_full_access = ["${list(module.build.role_arn, aws_iam_role.default.arn)}"]
}

resource "aws_ecr_repository_policy" "default" {
  count      = "${length(var.ecr_repo_names)}"
  repository = "${element(aws_ecr_repository.default.*.name, count.index)}"
  policy     = "${data.aws_iam_policy_document.resource_full_access.json}"
}

resource "aws_ecr_repository" "default" {
  count = "${length(var.ecr_repo_names)}"
  name  = "${join(module.label.delimiter, list(module.label.id, var.ecr_repo_names[count.index], "repo"))}"
  tags  = "${module.label.tags}"
}

variable "max_image_count" {
  default = "20"
}

resource "aws_ecr_lifecycle_policy" "default" {
  count      = "${length(var.ecr_repo_names)}"
  repository = "${element(aws_ecr_repository.default.*.name, count.index)}"

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Rotate images when reach ${var.max_image_count} images stored",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${var.max_image_count}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "resource_full_access" {
  statement {
    sid    = "FullAccess"
    effect = "Allow"

    principals = {
      type = "AWS"

      identifiers = [
        "${local.principals_full_access}",
      ]
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]
  }
}

locals {
  registry_ids     = "${zipmap(var.ecr_repo_names, aws_ecr_repository.default.*.registry_id)}"
  repository_urls  = "${zipmap(var.ecr_repo_names, aws_ecr_repository.default.*.repository_url)}"
  repository_names = "${zipmap(var.ecr_repo_names, aws_ecr_repository.default.*.name)}"
}

output "registry_ids" {
  value       = "${local.registry_ids}"
  description = "Map of registry IDs"
}

output "repository_urls" {
  value       = "${local.repository_urls}"
  description = "Map of repository URLs"
}

output "repository_names" {
  value       = "${local.repository_names}"
  description = "Map of repository names"
}
