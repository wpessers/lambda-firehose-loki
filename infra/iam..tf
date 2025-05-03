resource "aws_iam_role" "ecs_execution_role" {
  name               = "alloy-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_policy.json
}

data "aws_iam_policy_document" "ecs_execution_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs-task.amazonaws.com"
      ]
    }
  }
}
