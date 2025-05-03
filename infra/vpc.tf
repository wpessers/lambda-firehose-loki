data "aws_vpc" "default" {
  id = var.default_vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [var.default_vpc_id]
  }
}
