resource "aws_route53_record" "mllec" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "mllec.akrour.fr"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
