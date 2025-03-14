resource "aws_lb" "web_alb" {
  name               = "${local.name}-${var.tags.component}" #roboshop-dev-web-alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.web_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.public_subnets_ids.value)
  # Split is splitting 2 subnets where 2 subnets are min required from load balancer

  #enable_deletion_protection = true

  tags = merge(
    var.common_tags,
    var.tags
  )
}

# Need to create listener to alb as listner is required for alb
# Now listener should be HTTPS as it is connected to web/public
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_ssm_parameter.acm_certificate_arn.value

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is from WEB ALB using HTTPS"
      status_code  = "200"
    }
}
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "web-${var.environment}"
      type    = "A"
      alias   = {
        name    = aws_lb.web_alb.dns_name # under load balancer in aws console
        zone_id = aws_lb.web_alb.zone_id # zone id under lb in console
      }
    }
  ]
}
