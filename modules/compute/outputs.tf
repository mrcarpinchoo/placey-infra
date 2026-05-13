output "api_endpoint" {
  description = "API Gateway invoke URL"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}"
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.main.id
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.functions : k => v.arn }
}
