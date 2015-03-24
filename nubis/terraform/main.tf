# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

provider "consul" {
    address = "${var.consul}:8500"
    datacenter = "${var.region}"
}

resource "consul_keys" "app" {
    # Read the launch AMI from Consul
    key {
        name = "ami"
        path = "nubis/${var.project}/releases/${var.release}.${var.build}/${var.region}"
    }
}

resource "aws_security_group" "simple" {
  name = "${var.project}-simple-access"
  description = "Allow SSH"
  
  // These are for internal traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for fluentd clients
  ingress {
    from_port = 24224
    to_port = 24224
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 24224
    to_port = 24224
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "node" {
  ami = "${consul_keys.app.var.ami}"
  
  instance_type = "m3.medium"
  key_name = "${var.key_name}"
  
  security_groups = [
    "${aws_security_group.simple.name}",
  ]
  
  tags {
        Name = "Nubis ${var.project} (v/${var.release}.${var.build})"
        Release = "${var.release}.${var.build}"
  }

  user_data = "CONSUL_PUBLIC=1\nCONSUL_DC=${var.region}\nCONSUL_SECRET=${var.secret}\nCONSUL_JOIN=${var.consul}"
}
