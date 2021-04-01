resource "aws_efs_file_system" "pypi_server_disk" {
  creation_token = "pypi-server-data"
}
