resource "aws_ecs_cluster" "alloy" {
  name = "alloy-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "fargate_spot_provider" {
  cluster_name       = aws_ecs_cluster.alloy.name
  capacity_providers = ["FARGATE_SPOT"]
}

resource "aws_ecs_task_definition" "alloy" {
  family                   = "alloy"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 2048

  task_role_arn      = ""
  execution_role_arn = ""

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
        }
      ]
    }
  ])
}
