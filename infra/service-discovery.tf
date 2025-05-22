resource "aws_service_discovery_private_dns_namespace" "alloy" {
  name        = "test.alloy.local"
  description = "alloy private namespace"
  vpc         = data.aws_vpc.default.id
}

resource "aws_service_discovery_service" "alloy" {
  name = "alloy"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.alloy.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}
