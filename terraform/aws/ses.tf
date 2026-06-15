resource "aws_ses_domain_identity" "domain" {
  domain = var.domain_name
}

resource "aws_route53_record" "ses_verification" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = 300
  records = [aws_ses_domain_identity.domain.verification_token]
}

resource "aws_ses_domain_identity_verification" "domain" {
  domain     = aws_ses_domain_identity.domain.id
  depends_on = [aws_route53_record.ses_verification]
}
