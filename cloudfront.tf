#---------------------------------
# Local Variables
#---------------------------------
locals {
  s3_origin_id   = "${var.s3_name}-origin"
  s3_domain_name = "${var.s3_name}.s3-website.${var.region}.amazonaws.com"
}

#---------------------------------
# CloudFront OAC
#---------------------------------
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  description                       = "Grant cloudfront access to s3 bucket ${aws_s3_bucket.dnfrepo.id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#---------------------------------
# CloudFront Distribution
#---------------------------------
resource "aws_cloudfront_distribution" "dnfrepo" {
  depends_on = [
    aws_s3_bucket.dnfrepo
  ]

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  
  origin {
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    domain_name              = aws_s3_bucket.dnfrepo.bucket_regional_domain_name
  }

  custom_error_response {
    error_code = 404
    response_page_path = "/404.html"
    response_code = 404
  }

  custom_error_response {
    error_code = 403
    response_page_path = "/404.html"
    response_code = 404
  }

  default_cache_behavior {
    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Only include aliases if domain_name variable is populated
  dynamic "aliases" {
    for_each = var.domain_name != "" ? [var.domain_name] : []
    content {
      domain_name = aliases.value
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
  
}

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