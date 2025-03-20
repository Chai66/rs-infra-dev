resource "aws_acm_certificate" "devopspilot" {
  domain_name       = "devopspilot.online"
  validation_method = "DNS"

  tags = merge(
    var.tags,
    var.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Records created from above were used to copy in hosted zone as part of certicate validation

resource "aws_route53_record" "devopspilot" {
  for_each = {
    for dvo in aws_acm_certificate.devopspilot.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 1
  type            = each.value.type
  zone_id         = data.aws_route53_zone.devopspilot.zone_id
}

# DNS Validation with Route53
resource "aws_acm_certificate_validation" "devopspilot" {
  certificate_arn         = aws_acm_certificate.devopspilot.arn
  validation_record_fqdns = [for record in aws_route53_record.devopspilot : record.fqdn]
}