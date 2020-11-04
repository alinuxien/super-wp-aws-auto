locals {
  custom_origin_id = "mon_origine_alb"
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
      origin_ssl_protocols   = ["SSLv3"]
    }
  }

  price_class = "PriceClass_100"

  aliases = ["mllec.akrour.fr"]

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["FR"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.mllec_cloudfront.arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.custom_origin_id

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]

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
