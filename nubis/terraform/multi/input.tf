variable aws_profile {
}

variable aws_region {
}

variable aws_account_id {

}

variable key_name {
}

variable nubis_version {
}

variable nubis_domain {
}

variable service_name {
}

variable environments {
}

variable enabled {
}

variable monitoring_enabled {
  default = 0
}

variable technical_contact {
}

variable zone_id {
}

variable vpc_ids {
}

variable subnet_ids {
}

variable ssh_security_groups {
}

variable internet_access_security_groups {
}

variable shared_services_security_groups {
}

variable lambda_uuid_arn {
}

variable project {
  default = "fluent-collector"
}

variable sqs_queues {}
variable sqs_access_keys {}
variable sqs_secret_keys {}
variable sqs_regions {}

variable credstash_key {}

variable nubis_sudo_groups {
  default = "nubis_global_admins"
}

variable nubis_user_groups {
  default = ""
}
