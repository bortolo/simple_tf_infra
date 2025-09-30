

module "security_group_vpc_endpoint" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "security-group-vpc-endpoint"
  description = "Security group for vpc endpoint for api gw"
  vpc_id      = data.aws_vpc.imported_vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags

}


resource "aws_vpc_endpoint" "api_gw" {
  vpc_id            = data.aws_vpc.imported_vpc.id
  service_name      = "com.amazonaws.eu-central-1.execute-api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [data.aws_subnets.imported_vpc_subnets.ids[0]]
  security_group_ids = [module.security_group_vpc_endpoint.security_group_id]
  private_dns_enabled = true #AWS crea un DNS privato per il servizio execute-api

  # Abilitare private_dns_enabled = true senza considerare che cattura tutte 
  # le risoluzioni *.execute-api.* nella VPC → può rompere accesso a API pubbliche

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "arn:aws:execute-api:eu-central-1:152371567679:${aws_api_gateway_rest_api.private_api.id}/*"
      }
    ]
  })

  tags = local.tags
}
