variable "api_custom_domain_cloudfront_domain_name" {
  type = string
}

variable "api_custom_domain_cloudfront_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "rest_api" {
  description = "The API Gateway REST API resource"
}

variable "stage_name" {
  type = string
}

variable "sender_email" {
  type        = string
  description = "Email address for sending contact form submissions via SES."
}

variable "sendto_email" {
  type        = string
  description = "Email address to receive contact form submissions."
}
