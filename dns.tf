# DNS Hosted Zone
/*
resource "aws_route53_zone" "victor" {
  name = "victorponce.com"
} */
/*----------------- START -------------------*/
data "aws_route53_zone" "victorponce" {
  name         = "victorponce.site"
  private_zone = false
}

# DNS Record = Alias
resource "aws_route53_record" "lb" {
  zone_id = data.aws_route53_zone.victorponce.zone_id #aws_route53_zone.victor.zone_id
  name    = "victorponce.site"
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
/*------------------ FIN -------------*/
#create ACM certificate | register custom domain with APIGW domain
resource "aws_acm_certificate" "api_cert" { #must enable certificate in the aws console by creating registry in R53 public zone
  domain_name               = "victorponce.site"
  subject_alternative_names = ["victorponce.site"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
} 
/* #CHECK THIS CONFIGURATION https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.victorponce.zone_id
}

#Certification Validation | Validates DNS by "CREATE RECORDS IN ROUTE 53"
resource "aws_acm_certificate_validation" "dns" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [aws_route53_record.lb.fqdn]
} */

#TIP; if aws_acm_certificate_validation is not used: The first might fail because the LB's Listener needs a valid certificate (status issued)
#   After the first execution, we must "CREATE RECORDS IN ROUTE 53" so the status of the certificate changes to "ISSUED"
#   then in the second execution it will pass. 