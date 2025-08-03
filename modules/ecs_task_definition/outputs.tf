output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "container_name" {
  description = "The name of the container defined in the task"
  value       = var.container_name
}
