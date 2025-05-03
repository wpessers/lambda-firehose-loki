data "aws_iam_policy_document" "ecs_execution_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "alloy-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_policy.json
}

data "aws_iam_policy" "ecs_task_execution_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ssm_policy_document" {
  statement {
    effect    = "Allow"
    actions   = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [aws_ssm_parameter.alloy_config.arn]
  }
}

resource "aws_iam_policy" "ssm_policy" {
  name   = "ecs-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_policy_document.json
}

resource "aws_iam_role_policy_attachments_exclusive" "name" {
  role_name = aws_iam_role.ecs_execution_role.name
  policy_arns = [
    data.aws_iam_policy.ecs_task_execution_policy.arn,
    aws_iam_policy.ssm_policy.arn
  ]
}
