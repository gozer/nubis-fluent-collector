# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "aws_security_group" "collector" {
  name = "${var.project}-access-${var.release}-${var.build}"
  description = "Allow SSH"
  
  vpc_id = "${var.vpc_id}"
  
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
  ami = "${var.ami}"
  
  iam_instance_profile = "${var.iam_instance_profile}"
  subnet_id = "${var.subnet_id}"
  
  instance_type = "m3.medium"
  key_name = "${var.key_name}"
  
  security_groups = [
    "${aws_security_group.collector.id}",
  ]
  
  tags {
        Name = "Nubis ${var.project} (v/${var.release}.${var.build})"
        Release = "${var.release}.${var.build}"
  }
  
  user_data = "NUBIS_PROJECT=${var.project}\nNUBIS_ENVIRONMENT=${var.environment}\nCONSUL_PUBLIC=0\nCONSUL_DC=${var.region}\nCONSUL_SECRET=${var.consul_secret}\nCONSUL_JOIN=${var.consul}\nCONSUL_KEY=\"${file("${var.consul_ssl_key}")}\"\nCONSUL_CERT=\"${file("${var.consul_ssl_cert}")}\"\n"
}
