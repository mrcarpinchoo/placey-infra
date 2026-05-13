locals {
  functions = {
    search-places = "Proximity search — GET /places"
    get-place     = "Place details — GET /places/{placeId}"
  }
}

# Inline placeholder zip — replaced by backend deploy pipeline
data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "exports.handler = async () => ({ statusCode: 200, body: JSON.stringify({ message: 'placeholder' }) });"
    filename = "index.js"
  }
}

# Lambda functions
resource "aws_lambda_function" "functions" {
  for_each = local.functions

  function_name    = "placey-${var.environment}-${each.key}"
  description      = each.value
  role             = var.lambda_role_arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  memory_size      = 256
  timeout          = 30

  vpc_config {
    subnet_ids         = [var.app_subnet_id]
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      DB_SECRET_ARN     = var.rds_secret_arn
      DB_PROXY_ENDPOINT = var.rds_proxy_endpoint
      NODE_ENV          = var.environment
    }
  }

  tags = var.tags
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "main" {
  name          = "placey-${var.environment}-api"
  protocol_type = "HTTP"
  description   = "Placey REST API — ${var.environment}"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["Content-Type"]
    max_age       = 300
  }

  tags = var.tags
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true
}

# Lambda integrations
resource "aws_apigatewayv2_integration" "functions" {
  for_each = local.functions

  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.functions[each.key].invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "search_places" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /places"
  target    = "integrations/${aws_apigatewayv2_integration.functions["search-places"].id}"
}

resource "aws_apigatewayv2_route" "get_place" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /places/{placeId}"
  target    = "integrations/${aws_apigatewayv2_integration.functions["get-place"].id}"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each = local.functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
