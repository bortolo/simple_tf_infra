# ==== REST ======
# L’endpoint della REST API è più “astratto”. Per avere un dominio stabile e accesso privato devi:
# Creare Custom Domain (aws_api_gateway_domain_name)
# Collegarlo allo stage (aws_api_gateway_base_path_mapping)
# Creare deployment + stage (aws_api_gateway_deployment)
# Eventualmente aggiungere Route 53 record per avere un nome CNAME stabile
# Solo così puoi fare un accesso privato stabile e usare resource policy per consentire solo il VPCE.

resource "aws_api_gateway_rest_api" "private_api" {
  name        = var.apigw_rest_name
  description = "REST API privata solo per VPC endpoint"

  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_deployment" "private_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id

  # triggers serve per forzare un nuovo deployment quando cambia la REST API.
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

resource "aws_api_gateway_stage" "all" {
  for_each = var.apigw_rest_stages

  stage_name    = each.value
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  deployment_id = aws_api_gateway_deployment.private_api_deploy.id

  variables = {
    lambdaAlias = each.value
  }

}

# resource "aws_api_gateway_stage" "prod_stage" {
#   stage_name    = "prod"
#   rest_api_id   = aws_api_gateway_rest_api.private_api.id
#   deployment_id = aws_api_gateway_deployment.private_api_deploy.id

#     variables = {
#     lambdaAlias = "prod"
#   }

# }

# resource "aws_api_gateway_stage" "test_stage" {
#   stage_name    = "test"
#   rest_api_id   = aws_api_gateway_rest_api.private_api.id
#   deployment_id = aws_api_gateway_deployment.private_api_deploy.id

#     variables = {
#     lambdaAlias = "test"
#   }

# }

# Risorse
resource "aws_api_gateway_resource" "all" {
  for_each = var.apigw_rest_paths

  rest_api_id = aws_api_gateway_rest_api.private_api.id
  parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
  path_part   = each.value.resource
}

# Metodi
resource "aws_api_gateway_method" "all" {
  for_each = var.apigw_rest_paths

  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  resource_id   = aws_api_gateway_resource.all[each.value.resource].id
  http_method   = each.value.method
  authorization = "NONE"
}

# # Integrations
# resource "aws_api_gateway_integration" "all" {
#   for_each = {
#     lambda_status = { resource = "status", method = "get_status", lambda = aws_lambda_function.my_lambda.invoke_arn }
#     lambda_graph  = { resource = "graph", method = "post_graph", lambda = aws_lambda_function.my_lambda.invoke_arn }
#     lambda_save  = { resource = "save", method = "post_save", lambda = aws_lambda_function.my_lambda.invoke_arn }
#   }

#   rest_api_id             = aws_api_gateway_rest_api.private_api.id
#   resource_id             = aws_api_gateway_resource.all[each.value.resource].id
#   http_method             = aws_api_gateway_method.all[each.value.method].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = each.value.lambda
# }

# Integrations per API Gateway usando alias
# resource "aws_api_gateway_integration" "all" {
#   for_each = {
#     lambda_status_prod = { resource = "status", method = "get_status", lambda = aws_lambda_alias.prod_lambda_alias.invoke_arn }
#     lambda_graph_prod  = { resource = "graph", method = "post_graph", lambda = aws_lambda_alias.prod_lambda_alias.invoke_arn }
#     lambda_save_prod   = { resource = "save", method = "post_save", lambda = aws_lambda_alias.prod_lambda_alias.invoke_arn }

#     lambda_status_test = { resource = "status", method = "get_status", lambda = aws_lambda_alias.test_lambda_alias.invoke_arn }
#     lambda_graph_test  = { resource = "graph", method = "post_graph", lambda = aws_lambda_alias.test_lambda_alias.invoke_arn }
#     lambda_save_test   = { resource = "save", method = "post_save", lambda = aws_lambda_alias.test_lambda_alias.invoke_arn }
#   }

#   rest_api_id             = aws_api_gateway_rest_api.private_api.id
#   resource_id             = aws_api_gateway_resource.all[each.value.resource].id
#   http_method             = aws_api_gateway_method.all[each.value.method].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = each.value.lambda
# }

resource "aws_api_gateway_integration" "all" {
  for_each = var.apigw_rest_paths

  rest_api_id             = aws_api_gateway_rest_api.private_api.id
  resource_id             = aws_api_gateway_resource.all[each.value.resource].id          # resource o method non cambia, cicli sempre sulla stessa lunghezza della mappa
  http_method             = aws_api_gateway_method.all[each.value.resource].http_method   # resource o method non cambia, cicli sempre sulla stessa lunghezza della mappa
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  # uri                     = "arn:aws:lambda:eu-central-1:152371567679:function:my_lambda:$${stageVariables.lambdaAlias}/invocations"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account}:function:${data.aws_lambda_function.imported_lambda.function_name}:$${stageVariables.lambdaAlias}/invocations"

  # API Gateway stage variables, che sono variabili “runtime” disponibili solo al momento della chiamata. L’URI dell’integration 
  # può includere ${stageVariables.<nome>} e API Gateway sostituirà quella variabile con il valore definito nello stage corrispondente.
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
