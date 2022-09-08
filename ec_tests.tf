resource "aws_security_group" "test_group" {
  name        = "test"
  description = "temp test"
  vpc_id      = data.aws_subnet.lb_subnet.vpc_id

  ingress {
    description = "local"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/12"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "test_group"
  }
}


resource "aws_network_interface" "tests" {
  count                   = 2
  subnet_id               = data.aws_subnet.lb_subnet.id
  security_groups         = [aws_security_group.test_group.id]
  private_ip_list_enabled = true
  private_ip_list         = [format("172.31.0.3%d", count.index + 1)]
}

resource "aws_instance" "tests" {
  count         = 2
  ami           = data.aws_ami.debian.id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.kmz.key_name
  network_interface {
    network_interface_id = aws_network_interface.tests[count.index].id
    device_index         = 0
  }
  user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
EOF
}

output "tests_public_ips" {
  value = aws_instance.tests[*].public_ip
}

output "tests_private_ips" {
  value = aws_instance.tests[*].private_ip
}
