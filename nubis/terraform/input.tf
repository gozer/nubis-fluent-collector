variable aws_region {}

variable key_name {}

variable nubis_version {}

variable nubis_domain {}

variable service_name {}

variable arenas {
  type = "list"
}

variable enabled {}

variable monitoring_enabled {
  default = 0
}

variable technical_contact {}

variable zone_id {}

variable vpc_ids {}

variable subnet_ids {}

variable monitoring_security_groups {}

variable ssh_security_groups {}

variable internet_access_security_groups {}

variable shared_services_security_groups {}

variable sso_security_groups {
  default = ""
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

# Default is in main.tf so modules can force the default value
variable instance_type {
  default = ""
}
