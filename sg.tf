resource "aws_security_group" "pypi_ecs_security_group" {
  name   = format("%s-ecs-sg", local.pypi_service_name)
  vpc_id = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
