resource "aws_cloudfront_distribution" "hass" {
  origin {
    domain_name     = "dera.${var.domain_squiggle}"
    origin_id       = "dera.${var.domain_squiggle}-${var.environment}" 

    custom_origin_config {
      https_port = 4430
      http_port = 8080
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["SSLv3", "TLSv1", "TLSv1.1"]
    }
  }

  aliases = ["hass.${var.domain_squiggle}"]
  comment = "hass.${var.domain_squiggle}"

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  default_cache_behavior {
    viewer_protocol_policy = "allow-all"
    target_origin_id = "dera.${var.domain_squiggle}-${var.environment}" 

    allowed_methods = ["GET", "HEAD", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.hass.arn
    ssl_support_method = "sni-only"
  }

}

resource "aws_acm_certificate" "hass" {
  domain_name               = "hass.${var.domain_squiggle}"
  subject_alternative_names = ["hass.${var.domain_squiggle}"]
  validation_method         = "DNS"
  provider                  = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "hass" {
  certificate_arn         = aws_acm_certificate.hass.arn
  validation_record_fqdns = [for record in aws_route53_record.hass_validation : record.fqdn]
  provider                = aws.virginia
}

data "aws_route53_zone" "squiggle" {
  name         = var.domain_squiggle
  private_zone = false
}

resource "aws_route53_record" "hass_validation" {
  for_each = {
    for dvo in aws_acm_certificate.hass.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.squiggle.zone_id
}

resource "aws_route53_record" "hass_ipv4" {
  zone_id = data.aws_route53_zone.squiggle.zone_id
  name    = "hass.${var.domain_squiggle}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.hass.domain_name
    zone_id                = aws_cloudfront_distribution.hass.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "hass_ipv6" {
  zone_id = data.aws_route53_zone.squiggle.zone_id
  name    = "hass.${var.domain_squiggle}"
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.hass.domain_name
    zone_id                = aws_cloudfront_distribution.hass.hosted_zone_id
    evaluate_target_health = true
  }
}