// cheapo shell box

resource "aws_instance" "xenon" {
  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = true
  instance_type               = "t4g.nano"
  key_name                    = "geoff"
  user_data                   = filebase64("${path.module}/src/xenon-userdata.sh")
  vpc_security_group_ids      = [aws_security_group.xenon.id]
  tags = {
    Name = "xenon-${var.environment}"
  }
}

resource "aws_security_group" "xenon" {
  name        = "xenon-${var.environment}"
  description = "Xenon traffic"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description = "Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "xenon-${var.environment}"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"] 
  }

}

data "aws_route53_zone" "squiggle-org" {
  name         = "squiggle.org"
  private_zone = false
}

resource "aws_route53_record" "xenon" {
  zone_id = data.aws_route53_zone.squiggle-org.zone_id
  name    = "xenon.squiggle.org"
  type    = "A"
  ttl     = 300
  records = [aws_instance.xenon.public_ip]
}

output "ec2_ip" {
  value = aws_instance.xenon.public_ip
}