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
      environment = [
        {
          name  = "GCLOUD_HOSTED_METRICS_URL"
          value = "https://prometheus-prod-24-prod-eu-west-2.grafana.net/api/prom/push"
        },
        {
          name  = "GCLOUD_HOSTED_LOGS_URL"
          value = "https://logs-prod-012.grafana.net/loki/api/v1/push"
        },
        {
          name  = "GCLOUD_FM_URL"
          value = "https://fleet-management-prod-011.grafana.net"
        },
        {
          name  = "GCLOUD_FM_POLL_FREQUENCY"
          value = "60s"
        },
        {
          name  = "ARCH"
          value = "arm64"
        }
      ]
      secrets = [
        {
          name      = "ALLOY_CONFIG_FILE"
          valueFrom = "${aws_ssm_parameter.alloy_config.arn}"
        },
        {
          name      = "GCLOUD_RW_API_KEY"
          valueFrom = "${data.aws_secretsmanager_secret.grafana_cloud_api_key.arn}"
        },
        {
          name      = "GCLOUD_HOSTED_METRICS_ID"
          valueFrom = "${data.aws_secretsmanager_secret.grafana_cloud_hosted_metrics_id.arn}"
        },
        {
          name      = "GCLOUD_HOSTED_LOGS_ID"
          valueFrom = "${data.aws_secretsmanager_secret.grafana_cloud_hosted_logs_id.arn}"
        },

        {
          name      = "GCLOUD_FM_HOSTED_ID"
          valueFrom = "${data.aws_secretsmanager_secret.grafana_cloud_fleet_manager_id.arn}"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.alloy.name,
          awslogs-region        = var.aws_region
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
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    assign_public_ip = true
    subnets          = data.aws_subnets.default.ids
  }
}
