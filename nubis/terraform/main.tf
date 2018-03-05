provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

module "fluentd-image" {
  source = "github.com/nubisproject/nubis-terraform///images?ref=develop"

  region  = "${var.aws_region}"
  version = "${var.nubis_version}"
  project = "nubis-fluentd-collector"
}

resource "aws_s3_bucket" "fluent" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  bucket_prefix = "fluent-${element(var.arenas, count.index)}-"

  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name   = "${var.project}-${element(var.arenas, count.index)}"
    Region = "${var.aws_region}"
    Arena  = "${element(var.arenas, count.index)}"
  }
}

resource "aws_s3_bucket" "elb" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  bucket_prefix = "fluent-elb-${element(var.arenas, count.index)}-"

  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name   = "${var.project}-${element(var.arenas, count.index)}"
    Region = "${var.aws_region}"
    Arena  = "${element(var.arenas, count.index)}"
  }
}

data "aws_elb_service_account" "elb" {}

resource "aws_s3_bucket_policy" "elb" {
  count  = "${var.enabled * length(var.arenas)}"
  bucket = "${element(aws_s3_bucket.elb.*.id, count.index)}"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Allow ELBs to publish logs here",
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "${element(aws_s3_bucket.elb.*.arn, count.index)}/*",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.elb.arn}"
      }
    }
  ]
}
POLICY
}

resource "aws_security_group" "fluent-collector" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.project}-${element(var.arenas, count.index)}-"
  description = "Jumphost for SSH"

  vpc_id = "${element(split(",",var.vpc_ids), count.index)}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${element(split(",",var.ssh_security_groups), count.index)}",
    ]
  }

  # ES Proxy
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"

    security_groups = [
      "${element(split(",",var.monitoring_security_groups), count.index)}",
      "${element(split(",",var.sso_security_groups), count.index)}",
    ]
  }

  ingress {
    from_port = 24224
    to_port   = 24224
    protocol  = "tcp"

    security_groups = [
      "${element(split(",",var.shared_services_security_groups), count.index)}",
    ]
  }

  ingress {
    from_port = 24224
    to_port   = 24224
    protocol  = "udp"

    security_groups = [
      "${element(split(",",var.shared_services_security_groups), count.index)}",
    ]
  }

  ingress {
    from_port = 514
    to_port   = 514
    protocol  = "udp"

    security_groups = [
      "${element(split(",",var.shared_services_security_groups), count.index)}",
    ]
  }

  ingress {
    from_port   = "0"
    to_port     = "8"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Put back Amazon Default egress all rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "${var.project}-${element(var.arenas, count.index)}"
    Region = "${var.aws_region}"
    Arena  = "${element(var.arenas, count.index)}"
  }
}

resource "aws_iam_instance_profile" "fluent-collector" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  name = "${var.project}-${element(var.arenas, count.index)}-${var.aws_region}"

  role = "${element(aws_iam_role.fluent-collector.*.name, count.index)}"
}

resource "aws_iam_role" "fluent-collector" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  name = "${var.project}-${element(var.arenas, count.index)}-${var.aws_region}"
  path = "/nubis/${var.project}/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "fluent-collector" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  name = "${var.project}-bucket-${element(var.arenas, count.index)}-${var.aws_region}"
  role = "${element(aws_iam_role.fluent-collector.*.id, count.index)}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
              {
              "Sid": "SeeAllBuckets",
              "Effect": "Allow",
              "Action": "s3:ListAllMyBuckets",
              "Resource": "arn:aws:s3:::*"
            },
            {
              "Sid": "ListInOurBuckets",
              "Effect": "Allow",
              "Action": [
                "s3:ListBucket"
              ],
              "Resource": [
	          "${element(aws_s3_bucket.fluent.*.arn, count.index)}",
		  "${element(aws_s3_bucket.elb.*.arn, count.index)}"
	       ]
            },
            {
              "Sid": "FullAccessToOurBucket",
              "Effect": "Allow",
              "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
              ],
              "Resource": "${element(aws_s3_bucket.fluent.*.arn, count.index)}/*"
            },
	    {
              "Sid": "ReadingFromELBBucket",
              "Effect": "Allow",
              "Action": [
                "s3:GetObject"
              ],
              "Resource": "${element(aws_s3_bucket.elb.*.arn, count.index)}/*"
            }
  ]
}
POLICY
}

resource "aws_launch_configuration" "fluent-collector" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  # XXX: Should work, but doesn's, so see NUBIS_BUMP below
  depends_on = [
    "null_resource.secrets",
  ]

  name_prefix = "${var.project}-${element(var.arenas, count.index)}-${var.aws_region}-"

  image_id = "${module.fluentd-image.image_id}"

  # Default here, so modules can force the default value with an empty value
  instance_type        = "${var.instance_type == "" ? "t2.nano" : var.instance_type}"
  key_name             = "${var.key_name}"
  iam_instance_profile = "${element(aws_iam_instance_profile.fluent-collector.*.name, count.index)}"

  enable_monitoring = true

  security_groups = [
    "${element(aws_security_group.fluent-collector.*.id, count.index)}",
    "${element(split(",",var.internet_access_security_groups), count.index)}",
    "${element(split(",",var.shared_services_security_groups), count.index)}",
    "${element(split(",",var.ssh_security_groups), count.index)}",
  ]

  user_data = <<EOF
NUBIS_PROJECT="${var.project}"
NUBIS_ARENA="${element(var.arenas, count.index)}"
NUBIS_ACCOUNT="${var.service_name}"
NUBIS_DOMAIN="${var.nubis_domain}"
NUBIS_FLUENT_BUCKET="${element(aws_s3_bucket.fluent.*.id, count.index)}"
NUBIS_ELB_BUCKET="${element(aws_s3_bucket.elb.*.id, count.index)}"
NUBIS_FLUENT_ES_ENDPOINT="${element(concat(aws_elasticsearch_domain.fluentd.*.endpoint, list("")), 0)}"
NUBIS_FLUENT_SQS_QUEUE="${element(split(",",var.sqs_queues), count.index)}"
NUBIS_FLUENT_SQS_QUEUE_REGION="${element(split(",",var.sqs_regions), count.index)}"
NUBIS_FLUENT_SQS_ACCESS_KEY="${element(split(",",var.sqs_access_keys), count.index)}"
NUBIS_BUMP="${sha256(element(split(",", var.sqs_secret_keys), count.index))}"
NUBIS_SUDO_GROUPS="${var.nubis_sudo_groups}"
NUBIS_USER_GROUPS="${var.nubis_user_groups}"
EOF
}

resource "aws_autoscaling_group" "fluent-collector" {
  count = "${var.enabled * length(var.arenas)}"

  lifecycle {
    create_before_destroy = true
  }

  #XXX: Fugly, assumes 3 subnets per arenas, bad assumption, but valid ATM
  vpc_zone_identifier = [
    "${element(split(",",var.subnet_ids), (count.index * 3) + 0 )}",
    "${element(split(",",var.subnet_ids), (count.index * 3) + 1 )}",
    "${element(split(",",var.subnet_ids), (count.index * 3) + 2 )}",
  ]

  name                      = "${var.project}-${element(var.arenas, count.index)} (LC ${element(aws_launch_configuration.fluent-collector.*.name, count.index)})"
  max_size                  = "2"
  min_size                  = "1"
  health_check_grace_period = 10
  health_check_type         = "EC2"
  desired_capacity          = "1"
  force_delete              = true
  launch_configuration      = "${element(aws_launch_configuration.fluent-collector.*.name, count.index)}"

  wait_for_capacity_timeout = "60m"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = "Fluent Collector (${var.nubis_version}) for ${var.service_name} in ${element(var.arenas, count.index)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ServiceName"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Arena"
    value               = "${element(var.arenas, count.index)}"
    propagate_at_launch = true
  }
}

resource "aws_elasticsearch_domain" "fluentd" {
  count       = "${var.enabled * var.monitoring_enabled}"
  domain_name = "${var.project}"

  elasticsearch_version = "5.1"

  # This will need tweakability via knobs
  cluster_config {
    instance_type  = "m3.medium.elasticsearch"
    instance_count = 2
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"

    # min/max depends on instance type
    volume_size = "50"
  }

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow Fluentd to inject",
      "Effect": "Allow",
      "Principal": {
        "AWS": [ ${join(",\n", formatlist("\"%v\"", aws_iam_role.fluent-collector.*.arn))} ]
      },
      "Action": [
        "es:ESHttpGet",
        "es:ESHttpHead",
        "es:ESHttpPost",
        "es:ESHttpPut",
        "es:ESHttpDelete"
      ],
      "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.project}/*"
    }
  ]
}
POLICY

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Name   = "${var.project}"
    Region = "${var.aws_region}"
    Arena  = "global"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# This null resource is responsible for publishing secrets to Unicreds
resource "null_resource" "secrets" {
  count = "${var.enabled * length(var.arenas)}"

  # Important to list here every variable that affects what needs to be put into credstash
  triggers {
    sqs_secret_key = "${element(split(",", var.sqs_secret_keys), count.index)}"
    region         = "${var.aws_region}"
    context        = "-E region:${var.aws_region} -E arena:${element(var.arenas, count.index)} -E service:${var.project}"
    unicreds       = "unicreds -r ${var.aws_region} put -k ${var.credstash_key} ${var.project}/${element(var.arenas, count.index)}"
    unicreds_rm    = "unicreds -r ${var.aws_region} delete -k ${var.credstash_key} ${var.project}/${element(var.arenas, count.index)}"
  }

  # Consul gossip secret
  provisioner "local-exec" {
    command = "${self.triggers.unicreds}/SQS/SecretKey '${element(split(",", var.sqs_secret_keys), count.index)}' ${self.triggers.context}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${self.triggers.unicreds_rm}/SQS/SecretKey"
  }
}
