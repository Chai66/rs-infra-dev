

resource "aws_lb" "app_alb" {
  name               = "${local.name}-${var.tags.component}" #roboshop-dev-app-alb
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnets_ids.value)
  # Split is splitting 2 subnets where 2 subnets are min required from load balancer

  #enable_deletion_protection = true

  tags = merge(
    var.common_tags,
    var.tags
  )
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn # listener
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response" 
    # we can give typ= fixed-response just to check by giving some text in meassge_body with status_code 200

    fixed_response {
      content_type = "text/plain"
      message_body ="Hi, This response is from APP ALB"
      status_code = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "*.app-${var.environment}"
      type    = "A"
      alias   = {
        name    = aws_lb.app_alb.dns_name # under load balancer in aws console
        zone_id = aws_lb.app_alb.zone_id # zone id under lb in console
      }
    }
  ]
}

