locals {
  custom_origin_id = "origine_alb"
}

resource "aws_cloudfront_distribution" "cloudfront" {
  enabled = true

  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = local.custom_origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  price_class = "PriceClass_100"

  aliases = ["mllec.akrour.fr"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.aws_acm_certificate.mllec_cloudfront.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.custom_origin_id

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    compress               = false
    viewer_protocol_policy = "allow-all"
    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "31536000"
  }
}
