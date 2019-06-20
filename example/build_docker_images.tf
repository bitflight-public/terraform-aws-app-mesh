locals {
  ecr_repo_names = ["colorteller", "gateway"]
}
module "build_docker_images" {
  source         = "./modules/docker-build-deploy-pipeline"
  context        = "${module.label.context}"
  ecr_repo_names = ["${local.ecr_repo_names}"]

  ecr_repo_source_paths = {
    "colorteller" = "${path.module}/apps/src/colorteller"
    "gateway"     = "${path.module}/apps/src/gateway"
  }
}

output "image_repos" {
  value = "${module.build_docker_images.repository_urls}"
}

resource "aws_ssm_parameter" "repository_urls" {
  count = "${length(local.ecr_repo_names)}"
  name  = "/CodeBuild/${local.ecr_repo_names[count.index]}_repo_uri"
  type  = "String"
  value = "${module.build_docker_images.repository_urls[local.ecr_repo_names[count.index]]}"
}


