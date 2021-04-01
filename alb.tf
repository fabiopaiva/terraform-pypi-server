resource "aws_alb" "pypi_server" {
  name = format("%s-alb", local.pypi_service_name)
  subnets = module.vpc.public_subnets
}

resource "aws_alb_target_group" "pypi_server" {
  name = format("%s-alb-tg", local.pypi_service_name)
  port = 8080
  protocol = "HTTPS"
  vpc_id = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    interval            = 25
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = 200
  }

  depends_on = [aws_alb.pypi_server]
}


