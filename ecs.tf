locals {
  pypi_service_name  = "pypi"
  pypi_service_image = format("%s:v1.4.2", aws_ecr_repository.pypi_server.repository_url)
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "main-ecs-cluster"
}

resource "aws_ecs_service" "pypi_server" {
  name            = format("%s-server-service", local.pypi_service_name)
  task_definition = aws_ecs_task_definition.pypi_task.arn
  cluster         = aws_ecs_cluster.main_cluster.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.public_subnets // public for now
    assign_public_ip = true
    security_groups  = [aws_security_group.pypi_ecs_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.pypi_server.arn
    container_name   = local.pypi_service_name
    container_port   = 8080
  }

  depends_on = [aws_alb_target_group.pypi_server]
}

resource "aws_ecs_task_definition" "pypi_task" {
  family                   = local.pypi_service_name
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.pypi_ecs_task_role.arn
  execution_role_arn       = aws_iam_role.pypi_ecs_execution_role.arn
  container_definitions = jsonencode([{
    name      = local.pypi_service_name
    image     = local.pypi_service_image
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [
      {
        containerPort = 8080
        hostPort      = 8080
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.pypi_server_ecs_log_group.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "streaming"
      }
    }

    mountPoints = [{
      containerPath = "/data/packages"
      sourceVolume  = "service-storage"
    }]
  }])

  volume {
    name = "service-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.pypi_server_disk.id
      root_directory          = "/"
    }
  }
}
