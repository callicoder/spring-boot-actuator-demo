terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state"
    key          = "actuator-demo/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Toda la infra (red, ALB, ECS, IAM, ECR) vive en el módulo app.
module "app" {
  source = "../../modules/app"

  aws_region    = var.aws_region
  vpc_cidr      = var.vpc_cidr
  project_name  = var.project_name
  environment   = var.environment
  desired_count = var.desired_count
  min_capacity  = var.min_capacity
  max_capacity  = var.max_capacity

  alb_enable_https    = var.alb_enable_https
  alb_certificate_arn = var.alb_certificate_arn
  domain_name         = var.domain_name
  route53_zone_id     = var.route53_zone_id

  # Rellénalo con el ARN creado por el primer entorno, si compartes cuenta.
  github_oidc_provider_arn = var.github_oidc_provider_arn
}
