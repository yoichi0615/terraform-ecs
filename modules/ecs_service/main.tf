resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
