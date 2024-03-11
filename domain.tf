resource "aws_route53_record" "cloudfront_distribution" {
  count = var.domain_name != "" ? 1 : 0

  zone_id = var.hosted_zone_id  # Change to your Route 53 zone ID
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.dnfrepo.domain_name
    zone_id                = aws_cloudfront_distribution.dnfrepo.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cert" {
  provider = aws.us-east-1
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}