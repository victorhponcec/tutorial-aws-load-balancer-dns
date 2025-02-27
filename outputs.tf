#Retrieve AWS AZ Information
data "aws_region" "current" {}

output "current_region" {
  value = data.aws_region.current.name
}

output "instance_1_public_ip" {
  value = aws_instance.amazon_linux_lb1.public_ip
}

output "instance_2_public_ip" {
  value = aws_instance.amazon_linux_lb2.public_ip
}

output "lb_dns" {
  value = aws_lb.lb.dns_name
}