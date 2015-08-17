variable "IIM_AWS_ACCESS_KEY" {}
variable "IIM_AWS_SECRET_KEY" {}
variable "IIM_AWS_ZONE_ID" {}
variable "IIM_DOMAIN" {}
variable "IIM_SSH_USER" {}
variable "IIM_SSH_KEY_FILE" {}
variable "IIM_SSH_KEY_NAME" {}

variable "ip_marius" {
  default = "84.146.5.70/32"
}
variable "ip_kevin" {
  default = "62.163.187.106/32"
}
variable "ip_tim" {
  default = "24.134.75.132/32"
}
variable "ip_github" {
  default = "192.30.252.0/22"
}


provider "aws" {
  access_key = "${var.IIM_AWS_ACCESS_KEY}"
  secret_key = "${var.IIM_AWS_SECRET_KEY}"
  region     = "us-east-1"
}

variable "ami" {
  // http://cloud-images.ubuntu.com/locator/ec2/
  default = {
    us-east-1 = "ami-9bce7af0" // us-east-1	trusty	14.04 LTS	amd64	ebs-ssd	20150814 ami-9bce7af0
  }
}

variable "region" {
  default = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

resource "aws_instance" "infra-imagemagick-server" {
  ami = "${lookup(var.ami, var.region)}"
  instance_type = "c3.large"
  key_name = "${var.IIM_SSH_KEY_NAME}"
  security_groups = [
    "fw-infra-imagemagick-main"
  ]

  connection {
    user = "ubuntu"
    key_file = "${var.IIM_SSH_KEY_FILE}"
  }
}

resource "aws_route53_record" "www" {
  zone_id  = "${var.IIM_AWS_ZONE_ID}"
  name     = "${var.IIM_DOMAIN}"
  type     = "CNAME"
  ttl      = "300"
  records  = [ "${aws_instance.infra-imagemagick-server.public_dns}" ]
}

resource "aws_security_group" "fw-infra-imagemagick-main" {
  name = "fw-infra-imagemagick-main"
  description = "Infra Imagemagick"

  // Main SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.ip_kevin}",
      "${var.ip_marius}",
      "${var.ip_tim}"
    ]
  }

  // Main Web
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "${var.ip_github}",
      "${var.ip_kevin}",
      "${var.ip_marius}",
      "${var.ip_tim}"
    ]
  }
}

output "public_address" {
  value = "${aws_instance.infra-imagemagick-server.0.public_dns}"
}

output "public_addresses" {
  value = "${join(\"\n\", aws_instance.infra-imagemagick-server.*.public_dns)}"
}