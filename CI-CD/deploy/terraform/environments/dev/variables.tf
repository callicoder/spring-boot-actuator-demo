variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  type    = string
  default = "actuator-demo"
}

variable "environment" {
  type    = string
  default = "dev"
}

# Dimensionado del servicio ECS.
variable "desired_count" {
  type    = number
  default = 1
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "max_capacity" {
  type    = number
  default = 2
}

# HTTPS / dominio (opcional).
variable "alb_enable_https" {
  type    = bool
  default = false
}

variable "alb_certificate_arn" {
  type    = string
  default = null
}

variable "domain_name" {
  type    = string
  default = null
}

variable "route53_zone_id" {
  type    = string
  default = null
}

# Provider OIDC de GitHub ya existente (2º entorno en la misma cuenta AWS).
variable "github_oidc_provider_arn" {
  type    = string
  default = null
}
