output "api_endpoint" {
  description = "API Gateway invoke URL"
  value       = module.compute.api_endpoint
}

output "cloudfront_url" {
  description = "CloudFront distribution URL (frontend)"
  value       = module.frontend.cloudfront_url
}

output "s3_bucket_name" {
  description = "S3 bucket name for frontend assets"
  value       = module.frontend.s3_bucket_name
}

output "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint"
  value       = module.data.rds_proxy_endpoint
}
