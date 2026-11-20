output "ecr_repository_url" {
  value = module.app.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.app.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.app.ecs_service_name
}

output "cicd_role_arn" {
  value = module.app.cicd_role_arn
}

output "alb_url" {
  value = module.app.alb_url
}

output "cloudwatch_log_group" {
  value = module.app.cloudwatch_log_group
}
