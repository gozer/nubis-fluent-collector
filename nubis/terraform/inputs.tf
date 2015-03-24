# nubis-base
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "iam_instance_profile" {}

variable "environment" {
  description = "Name of the environment this deployment is for"
  default = "sandbox"
}

variable "consul" {
  description = "URL to Consul"
  default = "127.0.0.1"
}

variable "consul_secret" {
  description = "Security shared secret for consul membership (consul keygen)"
}

variable "consul_ssl_cert" {
  description = "SSL Certificate file"
  default = "consul.pem"
}

variable "consul_ssl_key" {
  description = "SSL Key file"
  default = "consul.key"
}

variable "region" {
  default = "us-west-2"
  description = "The region of AWS, for AMI lookups."
}

variable "release" {
  default = "0"
  description = "Release number of the architecture"
}

variable "build" {
  default = "2"
  description = "Build number of the architecture"
}

variable "project" {
  default = "fluent-collector"
  description = "Name of the project"
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "ami" {
  description = "Image ID"
}

variable "vpc_id" {
}

variable "subnet_id" {
}


