# ==== REST ======
# L’endpoint della REST API è più “astratto”. Per avere un dominio stabile e accesso privato devi:
# Creare Custom Domain (aws_api_gateway_domain_name)
# Collegarlo allo stage (aws_api_gateway_base_path_mapping)
# Creare deployment + stage (aws_api_gateway_deployment)
# Eventualmente aggiungere Route 53 record per avere un nome CNAME stabile
# Solo così puoi fare un accesso privato stabile e usare resource policy per consentire solo il VPCE.

resource "aws_api_gateway_rest_api" "private_api" {
  name        = "my-private-api"
  description = "REST API privata solo per VPC endpoint"

  endpoint_configuration {
    types = ["PRIVATE"]  # Endpoint privato
  }
}

resource "aws_api_gateway_rest_api_policy" "private_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "arn:aws:execute-api:${var.aws_region}:152371567679:${aws_api_gateway_rest_api.private_api.id}/*/*/*"
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = "${aws_vpc_endpoint.api_gw.id}"
          }
        }
      }
    ]
  })
}

# triggers serve per forzare un nuovo deployment quando cambia la REST API.
resource "aws_api_gateway_deployment" "private_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id

  triggers = {
    redeploy = sha1(jsonencode({
      resources    = [for r in aws_api_gateway_resource.all : r.id]
      methods      = [for m in aws_api_gateway_method.all : m.http_method]
      integrations = [for i in aws_api_gateway_integration.all : i.id]
    }))
  }

  depends_on = [
    aws_api_gateway_integration.all
  ]
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  deployment_id = aws_api_gateway_deployment.private_api_deploy.id
}

resource "aws_lambda_permission" "apigw_rest" {
  statement_id  = "AllowAPIGatewayInvokeREST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.private_api.execution_arn}/*/*" # Questo permette qualsiasi stage e qualsiasi metodo della tua API di invocare la Lambda
}

# Risorse
resource "aws_api_gateway_resource" "all" {
  for_each = {
    status = "status"
    graph  = "graph"
  }

  rest_api_id = aws_api_gateway_rest_api.private_api.id
  parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
  path_part   = each.value
}

# Metodi
resource "aws_api_gateway_method" "all" {
  for_each = {
    get_status  = { resource = "status", method = "GET" }
    post_graph  = { resource = "graph", method = "POST" }
  }

  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  resource_id   = aws_api_gateway_resource.all[each.value.resource].id
  http_method   = each.value.method
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "all" {
  for_each = {
    lambda_status = { resource = "status", method = "get_status", lambda = aws_lambda_function.my_lambda.invoke_arn }
    lambda_graph  = { resource = "graph", method = "post_graph", lambda = aws_lambda_function.my_lambda.invoke_arn }
  }

  rest_api_id             = aws_api_gateway_rest_api.private_api.id
  resource_id             = aws_api_gateway_resource.all[each.value.resource].id
  http_method             = aws_api_gateway_method.all[each.value.method].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda
}

# /status -----------------------------------

# resource "aws_api_gateway_resource" "status" {
#   rest_api_id = aws_api_gateway_rest_api.private_api.id
#   parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
#   path_part   = "status"
# }

# resource "aws_api_gateway_method" "get_status" {
#   rest_api_id   = aws_api_gateway_rest_api.private_api.id
#   resource_id   = aws_api_gateway_resource.status.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_status" {
#   rest_api_id = aws_api_gateway_rest_api.private_api.id
#   resource_id = aws_api_gateway_resource.status.id
#   http_method = aws_api_gateway_method.get_status.http_method
#   integration_http_method = "POST"
#   type        = "AWS_PROXY"
#   uri         = aws_lambda_function.my_lambda.invoke_arn
# }

# # /graph -----------------------------------

# resource "aws_api_gateway_resource" "graph" {
#   rest_api_id = aws_api_gateway_rest_api.private_api.id
#   parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
#   path_part   = "graph"
# }

# resource "aws_api_gateway_method" "post_graph" {
#   rest_api_id   = aws_api_gateway_rest_api.private_api.id
#   resource_id   = aws_api_gateway_resource.graph.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_graph" {
#   rest_api_id = aws_api_gateway_rest_api.private_api.id
#   resource_id = aws_api_gateway_resource.graph.id
#   http_method = aws_api_gateway_method.post_graph.http_method
#   integration_http_method = "POST"
#   type        = "AWS_PROXY"
#   uri         = aws_lambda_function.my_lambda.invoke_arn
# }


# Nel caso di soluzione B (custom domain con custom certificates) queste sono risorse da customizzare

# resource "aws_api_gateway_base_path_mapping" "rest_mapping" {
#   domain_name    = aws_api_gateway_domain_name.rest_domain.domain_name
#   api_id         = aws_api_gateway_rest_api.private_api.id
#   stage_name     = aws_api_gateway_stage.prod_stage.stage_name
#   domain_name_id = aws_api_gateway_domain_name.rest_domain.domain_name_id
# }


# # Per le REST API deve essere gestito il dominio endpoint e i suoi certificati (comunicazione via https)
# resource "aws_api_gateway_domain_name" "rest_domain" {
#   domain_name = "api.myapi.internal"

#   endpoint_configuration {
#     types = ["PRIVATE"]
#   }

#   certificate_arn = aws_acm_certificate.imported_cert.arn
#   # Trovare il modo di usare un certificato diverso e on prodotto dalla Pirave CA (servizio troppo costoso)
# }
