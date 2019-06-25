resource "aws_iam_role_policy" "instance_policy" {
  name = "${join(module.label.delimiter, list(module.label.id, "instance", "policy"))}"
  role = "${module.ecs_cluster.ecs_instance_role}"

  policy = "${data.aws_iam_policy_document.instance_policy.json}"
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "1"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:GetManifest",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
      "cloudwatch:PutMetricData",
      "ec2:DescribeInstanceStatus",
      "ds:CreateComputer",
      "ds:DescribeDirectories",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "s3:PutObject",
      "s3:GetObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      "*",
    ]
  }
}

# For ECS Service IAM Assume Role
# ManagedPolicyArns:
#         - arn:aws:iam::aws:policy/CloudWatchFullAccess
#         - arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess


# For ECS Task Execution Role
# ManagedPolicyArns:
#   - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
#   - arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

