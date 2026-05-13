variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to S3 bucket"
  type        = map(string)
}
