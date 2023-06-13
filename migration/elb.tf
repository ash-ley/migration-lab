resource "aws_lb" "this" {
  name                       = "migration-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = [for subnet in module.vpc.public_subnets : subnet]
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  #checkov:skip=CKV_AWS_91:Logging is to be enabled in a future implementation
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name     = "phpmyadmin"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id
  #checkov:skip=CKV_AWS_261:Target group has no attached instances so this is impossible for now
}

resource "aws_lb_listener_certificate" "this" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "phpmyadmin.ashley.aws.crlabs.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "migration"
  }
}

resource "aws_route53_zone" "public" {
  name = "ashley.aws.crlabs.cloud"
}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.public.zone_id
}

resource "aws_route53_record" "lb" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "phpmyadmin.ashley.aws.crlabs.cloud"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}
