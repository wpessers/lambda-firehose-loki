resource "aws_ecs_cluster" "alloy" {
  name = "alloy-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fargate_spot_provider" {
  cluster_name       = aws_ecs_cluster.alloy.name
  capacity_providers = ["FARGATE_SPOT"]
}

resource "aws_ecs_task_definition" "alloy" {
  depends_on = [aws_cloudwatch_log_group.alloy]

  family                   = "alloy"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu          = 512
  memory       = 1024

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name  = "alloy-collector",
      image = "grafana/alloy:latest"
      portMappings = [
        {
          containerPort = 12345,
          hostPort      = 12345,
          protocol      = "tcp"
        }
      ]
      entrypoint = [
        "sh",
        "-c",
        "echo $ALLOY_CONFIG_FILE | base64 -d > /etc/alloy/config.alloy; /bin/alloy run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data /etc/alloy/config.alloy"
      ]
      secrets = [
        {
          valueFrom = "${aws_ssm_parameter.alloy_config.arn}/ALLOY_CONFIG"
          name      = "ALLOY_CONFIG_FILE"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.alloy.name,
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "alloy"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "alloy" {
  name            = "alloy"
  cluster         = aws_ecs_cluster.alloy.id
  task_definition = aws_ecs_task_definition.alloy.arn
  desired_count   = 1

  network_configuration {
    subnets = data.aws_subnets.default.ids
  }
}
