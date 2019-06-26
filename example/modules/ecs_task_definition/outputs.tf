# The arn of the task definition
output "aws_ecs_task_definition_arn" {
  value = "${element(concat(
    aws_ecs_task_definition.app.*.arn, 
    aws_ecs_task_definition.app_with_docker_volume.*.arn,
    aws_ecs_task_definition.app_with_app_mesh.*.arn, 
    aws_ecs_task_definition.app_with_docker_volume_and_app_mesh.*.arn, 
    list("")), 0)}"
}

output "aws_ecs_task_definition_family" {
  value = "${element(concat(
    aws_ecs_task_definition.app.*.family, 
    aws_ecs_task_definition.app_with_docker_volume.*.family, 
    aws_ecs_task_definition.app_with_app_mesh.*.family, 
    aws_ecs_task_definition.app_with_docker_volume_and_app_mesh.*.family,
    list("")), 0)}"
}

output "aws_ecs_task_definition_revision" {
  value = "${element(concat(
    aws_ecs_task_definition.app.*.revision, 
    aws_ecs_task_definition.app_with_docker_volume.*.revision, 
    aws_ecs_task_definition.app_with_app_mesh.*.revision, 
    aws_ecs_task_definition.app_with_docker_volume_and_app_mesh.*.revision,
    list("")), 0)}"
}
