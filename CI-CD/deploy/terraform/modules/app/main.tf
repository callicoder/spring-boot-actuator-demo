# Módulo "app": toda la infra del entorno (red, ALB, ECS, IAM, ECR).
# El provider se hereda del root module, junto con sus default_tags.

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Red en 2 AZ; en dev un solo NAT gateway para abaratar.
  nat_gateway_count = var.environment == "dev" ? 1 : length(var.availability_zones)

  # Puerto público del ALB.
  alb_port = var.alb_enable_https ? 443 : 80
}

# ---------------------------------------------------------------------------
# Red: VPC, subredes, IGW, NAT y tablas de rutas
# ---------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Subredes públicas: ALB y NAT gateway. Privadas: tareas ECS.
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = "${var.aws_region}${var.availability_zones[count.index]}"
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone = "${var.aws_region}${var.availability_zones[count.index]}"
}

resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % local.nat_gateway_count].id
}

# ---------------------------------------------------------------------------
# ALB público frente a las tareas ECS
# ---------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name   = "${local.name_prefix}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = local.alb_port
    to_port     = local.alb_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app" {
  name            = substr("${local.name_prefix}-alb", 0, 32)
  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "app" {
  name        = substr("${local.name_prefix}-tg", 0, 32)
  port        = var.container_port
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path = var.alb_health_check_path
  }

  deregistration_delay = 30
}

# Listener principal: HTTPS con certificado; si no hay, HTTP directo en el 80.
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = local.alb_port
  protocol          = var.alb_enable_https ? "HTTPS" : "HTTP"
  ssl_policy        = var.alb_enable_https ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Con HTTPS, el puerto 80 solo redirige al 443.
resource "aws_lb_listener" "http" {
  count = var.alb_enable_https ? 1 : 0

  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Registro DNS opcional en Route 53.
resource "aws_route53_record" "app" {
  count = var.domain_name != null ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
