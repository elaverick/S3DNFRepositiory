
locals {
  s3_origin_id   = "${var.s3_name}-origin"
  s3_domain_name = "${var.s3_name}.s3-website.${var.region}.amazonaws.com"
}

resource "aws_cloudfront_distribution" "this" {
  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_website_configuration.this
  ]

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket_website_configuration.this.website_endpoint
  }

  custom_error_response {
    error_code = 404
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
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"
  
}