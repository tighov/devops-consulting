#!/usr/bin/env bash
set -euo pipefail

BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${1:-$BASEDIR/config.env}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    echo "Copy config.env.example or create config.env and try again."
    exit 1
fi

# ---------- Load config ----------
set -a
# shellcheck source=/dev/null
source "$CONFIG_FILE"
set +a

# ---------- Validate required vars ----------
missing=()
for var in DOMAIN_NAME PROJECT_NAME AWS_REGION CONTACT_EMAIL COPYRIGHT_YEAR CDN_DISTRIBUTION_ID; do
    if [ -z "${!var:-}" ]; then
        missing+=("$var")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Missing required variables in $CONFIG_FILE:"
    printf '  - %s\n' "${missing[@]}"
    exit 1
fi

# ---------- Derived values ----------
SITEURL="https://www.${DOMAIN_NAME}"
LAMBDA_ENDPOINT="https://api.${DOMAIN_NAME}/contact-form"
BUCKET_NAME="www.${DOMAIN_NAME}"
TF_STATE_BUCKET="${PROJECT_NAME}-tf"

echo "Configuring project with:"
echo "  DOMAIN_NAME        = $DOMAIN_NAME"
echo "  PROJECT_NAME       = $PROJECT_NAME"
echo "  AWS_REGION         = $AWS_REGION"
echo "  CONTACT_EMAIL      = $CONTACT_EMAIL"
echo "  COPYRIGHT_YEAR     = $COPYRIGHT_YEAR"
echo "  CDN_DISTRIBUTION_ID= $CDN_DISTRIBUTION_ID"
echo "  SITEURL            = $SITEURL"
echo "  LAMBDA_ENDPOINT    = $LAMBDA_ENDPOINT"
echo "  BUCKET_NAME        = $BUCKET_NAME"
echo "  TF_STATE_BUCKET    = $TF_STATE_BUCKET"
echo ""

# ---------- Helper: portable sed -i ----------
sedi() {
    if [[ "$OSTYPE" == darwin* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# ---------- pelicanconf.py ----------
FILE="$BASEDIR/pelicanconf.py"
sedi "s|^LAMBDA_ENDPOINT = .*|LAMBDA_ENDPOINT = 'https://api.${DOMAIN_NAME}/contact-form'|" "$FILE"
sedi "s|^COPYRIGHT_YEAR = .*|COPYRIGHT_YEAR = '${COPYRIGHT_YEAR}'|" "$FILE"
echo "  updated pelicanconf.py"

# ---------- publishconf.py ----------
FILE="$BASEDIR/publishconf.py"
sedi "s|^SITEURL = .*|SITEURL = '${SITEURL}'|" "$FILE"
echo "  updated publishconf.py"

# ---------- .github/workflows/deploy.yml ----------
FILE="$BASEDIR/.github/workflows/deploy.yml"
sedi "s|^  SITEURL: .*|  SITEURL: '${SITEURL}'|" "$FILE"
sedi "s|^  FEED_DOMAIN: .*|  FEED_DOMAIN: '${SITEURL}'|" "$FILE"
sedi "s|^  BUCKET_NAME: .*|  BUCKET_NAME: '${BUCKET_NAME}'|" "$FILE"
sedi "s|^  AWS_REGION: .*|  AWS_REGION: '${AWS_REGION}'|" "$FILE"
echo "  updated .github/workflows/deploy.yml"

# ---------- Makefile ----------
FILE="$BASEDIR/Makefile"
sedi "s|^S3_BUCKET=.*|S3_BUCKET=${BUCKET_NAME}|" "$FILE"
echo "  updated Makefile"

# ---------- terraform/aws/providers.tf (rewrite to avoid clobbering ACM region) ----------
FILE="$BASEDIR/terraform/aws/providers.tf"
cat > "$FILE" <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "${TF_STATE_BUCKET}"
    key          = "prod.tfstate"
    region       = "${AWS_REGION}"
    use_lockfile = true
    encrypt      = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Configure the ACM Provider (must be us-east-1 for CloudFront certs)
provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}
EOF
echo "  updated terraform/aws/providers.tf"

# ---------- terraform/aws/terraform.tfvars ----------
FILE="$BASEDIR/terraform/aws/terraform.tfvars"
cat > "$FILE" <<EOF
domain_name  = "${DOMAIN_NAME}"
project_name = "${PROJECT_NAME}"
region       = "${AWS_REGION}"
common_tags = {
  Name        = "${PROJECT_NAME}"
  Environment = "prod"
  Owner       = "tigran"
}
stage_name   = "prod"
sender_email = "${CONTACT_EMAIL}"
sendto_email = "${CONTACT_EMAIL}"
EOF
echo "  updated terraform/aws/terraform.tfvars"

# ---------- terraform/aws-remote-state/variables.tf ----------
FILE="$BASEDIR/terraform/aws-remote-state/variables.tf"
cat > "$FILE" <<EOF
variable "project_name" {
  type        = string
  description = "Project name used for the state bucket"
  default     = "${PROJECT_NAME}"
}

variable "region" {
  type        = string
  default     = "${AWS_REGION}"
  description = "The AWS region to create the bucket in."
}
EOF
echo "  updated terraform/aws-remote-state/variables.tf"

# ---------- content/extra/robots.txt ----------
FILE="$BASEDIR/content/extra/robots.txt"
cat > "$FILE" <<EOF
User-agent: *
Disallow:
Sitemap: ${SITEURL}/sitemap.xml
EOF
echo "  updated content/extra/robots.txt"

# ---------- scripts/invalidate_cdn.sh ----------
FILE="$BASEDIR/scripts/invalidate_cdn.sh"
sedi "s|^CDN_DISTRIBUTION_ID=.*|CDN_DISTRIBUTION_ID=\"${CDN_DISTRIBUTION_ID}\"|" "$FILE"
echo "  updated scripts/invalidate_cdn.sh"

# ---------- theme/templates/base.html (match any email in footer <p> tag) ----------
FILE="$BASEDIR/theme/templates/base.html"
sedi "s|<p>[^<]*@[^<]*</p>|<p>${CONTACT_EMAIL}</p>|" "$FILE"
echo "  updated theme/templates/base.html"

echo ""
echo "Done. All files configured for domain: ${DOMAIN_NAME}"
echo ""
echo "Next steps:"
echo "  1. Run 'make remote-state' to bootstrap Terraform state bucket"
echo "  2. Run 'make plan' to preview infrastructure changes"
echo "  3. Run 'make apply' to provision AWS resources"
echo "  4. After first apply, get the CloudFront distribution ID and update"
echo "     CDN_DISTRIBUTION_ID in config.env, then run 'make configure' again"
echo "  5. Push to main branch to trigger GitHub Actions deployment"
