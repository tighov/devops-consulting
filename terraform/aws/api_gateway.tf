resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "api.${var.domain_name}"
  description = "API Gateway for contact/booking form"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = module.contact_form.stage_name
  domain_name = aws_api_gateway_domain_name.api_custom_domain.domain_name
}
