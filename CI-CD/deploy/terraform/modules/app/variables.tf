variable "aws_region" {
  description = "Región AWS donde se despliega la infraestructura."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base de los recursos (prefijo de los nombres)."
  type        = string
  default     = "actuator-demo"
}

variable "environment" {
  description = "Entorno lógico (dev | qa | prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment debe ser dev, qa o prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para las subredes."
  type        = list(string)
  default     = ["a", "b"]
}

variable "container_port" {
  description = "Puerto en el que escucha la aplicación dentro del contenedor."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Número de tareas deseadas en el servicio ECS."
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "CPU (milicores) por tarea Fargate."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memoria (MiB) por tarea Fargate."
  type        = number
  default     = 1024
}

variable "min_capacity" {
  description = "Mínimo de tareas en autoscaling."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Máximo de tareas en autoscaling."
  type        = number
  default     = 2
}

variable "cpu_autoscaling_target" {
  description = "Uso de CPU objetivo (%) para el escalado automático."
  type        = number
  default     = 60
}

variable "image_tag" {
  description = "Tag de la imagen en ECR para el despliegue inicial."
  type        = string
  default     = "latest"
}

variable "alb_health_check_path" {
  description = "Ruta usada por el ALB y por ECS para comprobar la salud."
  type        = string
  default     = "/actuator/health"
}

variable "alb_enable_https" {
  description = "Si es true, exige alb_certificate_arn y habilita el listener TLS."
  type        = bool
  default     = false
}

variable "alb_certificate_arn" {
  description = "ARN del certificado ACM (requerido si alb_enable_https=true)."
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Dominio opcional para el ALB (Route 53)."
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Zone ID de Route 53 (requerido si domain_name != null)."
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "Rangos CIDR con acceso permitido al ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "log_retention_days" {
  description = "Retención de los logs en CloudWatch Logs."
  type        = number
  default     = 30
}

variable "github_repo" {
  description = "Repositorio GitHub (owner/repo) autorizado a asumir el rol de CI/CD."
  type        = string
  default     = "alanvieyra333/spring-boot-actuator-demo"
}

variable "github_oidc_provider_arn" {
  description = "ARN de un OIDC provider de GitHub ya existente. Si se omite, se crea uno."
  type        = string
  default     = null
}
