data "aws_iam_policy_document" "pypi_ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pypi_ecs_task_role" {
  name               = format("%s-task-role", local.pypi_service_name)
  assume_role_policy = data.aws_iam_policy_document.pypi_ecs_task_assume_role.json
}

resource "aws_iam_role" "pypi_ecs_execution_role" {
  name               = format("%s-execution-role", local.pypi_service_name)
  assume_role_policy = data.aws_iam_policy_document.pypi_ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "pypi_ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.pypi_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "pypi_ecs_execution_role_policies" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [aws_ecr_repository.pypi_server.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pypi_ecs_execution_role_policies" {
  name = format("%sExecutionRoleAccess", local.pypi_service_name)
  policy = data.aws_iam_policy_document.pypi_ecs_execution_role_policies.json
  role   = aws_iam_role.pypi_ecs_execution_role.id
}

data "aws_iam_policy_document" "pypi_ecs_task_role_policies" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [aws_efs_file_system.pypi_server_disk.arn]
  }
}

resource "aws_iam_role_policy" "pypi_ecs_task_role_policies" {
  name = format("%sTaskRoleAccess", local.pypi_service_name)
  policy = data.aws_iam_policy_document.pypi_ecs_task_role_policies.json
  role   = aws_iam_role.pypi_ecs_task_role.id
}
