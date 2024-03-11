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

  aliases = var.domain_name != "" ? [var.domain_name] : []

  viewer_certificate {
    cloudfront_default_certificate = var.domain_name != "" ? false :true
    acm_certificate_arn            = var.domain_name != "" ? aws_acm_certificate_validation.cert.certificate_arn : null
    ssl_support_method             = var.domain_name != "" ? "sni-only" : null
  }

  price_class = "PriceClass_100"
}