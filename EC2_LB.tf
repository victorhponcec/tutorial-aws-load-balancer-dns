#EC2 Instances
resource "aws_instance" "amazon_linux_lb1" {
  ami                         = "ami-05576a079321f21f8"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web.id, aws_security_group.ssh.id]
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
  user_data                   = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>Hello World from AZA $(hostname -f)</h1>" > /var/www/html/index.html
            EOF 
}

resource "aws_instance" "amazon_linux_lb2" {
  ami                         = "ami-05576a079321f21f8"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web.id, aws_security_group.ssh.id]
  subnet_id                   = aws_subnet.public_subnet_b.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
  user_data                   = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>Hello World from AZB-Home $(hostname -f)</h1>" > /var/www/html/index.html
            echo "<h1>Hello World from AZB-Files $(hostname -f)</h1>" | sudo tee /var/www/html/files.html
            EOF
}