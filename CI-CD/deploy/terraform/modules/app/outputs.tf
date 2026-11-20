output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "cicd_role_arn" {
  value = aws_iam_role.cicd.arn
}

locals {
  # El dominio de Route 53 si existe; si no, el DNS del ALB.
  alb_hostname = var.domain_name != null ? var.domain_name : aws_lb.app.dns_name
}

output "alb_url" {
  value = "http${var.alb_enable_https ? "s" : ""}://${local.alb_hostname}"
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.app.name
}
