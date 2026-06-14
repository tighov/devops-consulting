terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "devops-consulting-tf"
    key          = "prod.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Configure the ACM Provider (us-east-1 for CloudFront certs)
provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}
