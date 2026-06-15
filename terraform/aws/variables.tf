variable "domain_name" {
  type        = string
  description = "Name of the domain"
}

variable "region" {
  type        = string
  description = "The AWS region to create the bucket in."
}

variable "common_tags" {
  description = "Common tags you want applied to all components."
}

variable "stage_name" {
  type        = string
  description = "The stage name for the API Gateway deployment."
}

variable "sender_email" {
  type        = string
  description = "Email address for sending contact form submissions via SES."
}

variable "sendto_email" {
  type        = string
  description = "Email address to receive contact form submissions."
}

variable "project_name" {
  type        = string
  description = "Project name used for AWS resource naming."
}
