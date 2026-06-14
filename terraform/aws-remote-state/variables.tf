variable "project_name" {
  type        = string
  description = "Project name used for the state bucket"
  default     = "devops-consulting"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to create the bucket in."
}
