data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["136693071363"]
}

resource "aws_key_pair" "kmz" {
  key_name   = "kmz"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESr7RepHsk0YZ2ZzOlciHygJBv5NU/XxdRew5QRiOPi kaveh"
}

data "aws_subnet" "lb_subnet" {
  filter {
    name   = "cidr-block"
    values = [var.subnet_cidr]
  }
}

locals {
  user_data = templatefile("init/init.tftpl", {
    haproxycfg = templatefile("config/haproxy.cfg.tftpl", {
      lb_binding = var.lb_binding,
    })
    lb_ips = var.lb_ips,
  })
}
