data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${module.label.id}"
  acl    = "private"
  tags   = "${module.label.tags}"
}

resource "aws_iam_role" "default" {
  name               = "${module.label.id}"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.default.arn}"
}

resource "aws_iam_policy" "default" {
  name   = "${module.label.id}"
  policy = "${data.aws_iam_policy_document.default.json}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
      "logs:PutRetentionPolicy",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_policy" "s3" {
  name   = "${module.label.id}-s3"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = ""

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.artifacts.arn}",
      "${aws_s3_bucket.artifacts.arn}/*",
      "arn:aws:s3:::elasticbeanstalk*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = "${aws_iam_role.default.id}"
  policy_arn = "${aws_iam_policy.codebuild.arn}"
}

resource "aws_iam_policy" "codebuild" {
  name   = "${module.label.id}-codebuild"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = ""

    actions = [
      "codebuild:*",
    ]

    resources = ["${module.build.project_id}"]
    effect    = "Allow"
  }
}

variable "build_image" {
  description = "CLI command to list all images: aws codebuild list-curated-environment-images"
  default     = "aws/codebuild/standard:2.0-1.10.0"
}

variable "privileged_mode" {
  default = true
}

variable "build_compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}

module "build" {
  source     = "git::https://github.com/cloudposse/terraform-aws-codebuild.git?ref=tags/0.16.0"
  namespace  = "${module.label.namespace}"
  name       = "${module.label.name}"
  stage      = "${module.label.stage}"
  delimiter  = "${module.label.delimiter}"
  attributes = "${concat(module.label.attributes, list("build"))}"

  build_image        = "${var.build_image}"
  build_compute_type = "${var.build_compute_type}"

  # buildspec          = "${var.buildspec}"
  privileged_mode = "${var.privileged_mode}"

  # image_repo_name       = "${var.image_repo_name}"
  cache_enabled = "false"

  # image_tag             = "${var.image_tag}"
  # github_token          = ""
  # environment_variables = "${var.environment_variables}"
}

variable "ecr_repo_source_paths" {
  type = "map"
}

data "archive_file" "docker_source" {
  count       = "${length(var.ecr_repo_names)}"
  type        = "zip"
  source_dir  = "${var.ecr_repo_source_paths[var.ecr_repo_names[count.index]]}"
  output_path = "${path.module}/${var.ecr_repo_names[count.index]}.zip"
}

resource "aws_s3_bucket_object" "objects" {
  count  = "${length(var.ecr_repo_names)}"
  bucket = "${aws_s3_bucket.artifacts.id}"
  key    = "${var.ecr_repo_names[count.index]}.zip"
  source = "${data.archive_file.docker_source.*.output_path[count.index]}"
  etag   = "${data.archive_file.docker_source.*.output_md5[count.index]}"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = "${module.build.role_id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_codepipeline" "source_build" {
  name     = "${module.label.id}"
  role_arn = "${aws_iam_role.default.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifacts.bucket}"
    type     = "S3"
  }

  # https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#action-requirements
  stage {
    name = "Source"

    action {
      # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions-actiontypeid.html
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"
      name     = "${var.ecr_repo_names[0]}SourceFromS3"

      configuration {
        S3Bucket             = "${aws_s3_bucket.artifacts.id}"
        S3ObjectKey          = "${var.ecr_repo_names[0]}.zip"
        PollForSourceChanges = "true"
      }

      output_artifacts = ["${var.ecr_repo_names[0]}"]
    }

    action {
      # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-pipeline-stages-actions-actiontypeid.html
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"
      name     = "${var.ecr_repo_names[1]}SourceFromS3"

      configuration {
        S3Bucket             = "${aws_s3_bucket.artifacts.id}"
        S3ObjectKey          = "${var.ecr_repo_names[1]}.zip"
        PollForSourceChanges = "true"
      }

      output_artifacts = ["${var.ecr_repo_names[1]}"]
    }
  }

  stage {
    name = "Build"

    action {
      name     = "${var.ecr_repo_names[0]}"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["${var.ecr_repo_names[0]}"]
      output_artifacts = ["package0"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }

    action {
      name     = "${var.ecr_repo_names[1]}"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["${var.ecr_repo_names[1]}"]
      output_artifacts = ["package1"]

      configuration {
        ProjectName = "${module.build.project_name}"
      }
    }
  }
}
