resource "aws_cloudwatch_log_group" "pypi_server_ecs_log_group" {
  name = format("%s-ecs", local.pypi_service_name)
  retention_in_days = 30
}
