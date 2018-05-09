// Adopt config-policy template
data "template_file" "aws_config_iam_password_policy" {
  template = "${file("${path.module}/config-policies/iam-password-policy.tpl")}"

  vars = {
    // terraform will interpolate boolean as 0/1 and the config parameters expect "true" or "false"
    password_require_uppercase = "${var.password_require_uppercase ? "true" : "false"}"
    password_require_lowercase = "${var.password_require_lowercase ? "true" : "false"}"
    password_require_symbols   = "${var.password_require_symbols ? "true" : "false"}"
    password_require_numbers   = "${var.password_require_numbers ? "true" : "false"}"
    password_min_length        = "${var.password_min_length}"
    password_reuse_prevention  = "${var.password_reuse_prevention}"
    password_max_age           = "${var.password_max_age}"
  }
}

data "template_file" "aws_config_acm_certificate_expiration" {
  template = "${file("${path.module}/config-policies/acm-certificate-expiration.tpl")}"

  vars = {
    acm_days_to_expiration = "${var.acm_days_to_expiration}"
  }
}

data "template_file" "aws_config_restricted_common_ports" {
  template = "${file("${path.module}/config-policies/restricted-common-ports.tpl")}"

  vars = {
    "blockedPort1" = "${var.blockedPort1}"
    "blockedPort2" = "${var.blockedPort2}"
    "blockedPort3" = "${var.blockedPort3}"
    "blockedPort4" = "${var.blockedPort4}"
    "blockedPort5" = "${var.blockedPort5}"
  }
}

data "template_file" "aws_config_require_tags" {
  template = "${file("${path.module}/config-policies/require-tags.tpl")}"

  vars = {
    "tag1Key" = "${var.tag1Key}"
    "tag2Key" = "${var.tag2Key}"
    "tag3Key" = "${var.tag3Key}"
  }
}

/**
 * AWS Config Rules (classfied each rule by category)
 * Reference link 1: https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
 * Reference link 2 (custom rules): https://github.com/awslabs/aws-config-rules
 */

// Compute
resource "aws_config_config_rule" "restricted-ssh" {
  name        = "restricted-ssh"
  description = "Checks whether security groups in use do not allow restricted incoming SSH traffic."

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = ["aws_config_configuration_recorder.main"]
}

resource "aws_config_config_rule" "restricted-common-ports" {
  name             = "restricted-common-ports"
  description      = "Checks whether security groups in use do not allow restricted incoming TCP traffic to the specified ports."
  input_parameters = "${data.template_file.aws_config_restricted_common_ports.rendered}"

  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }

  depends_on = [
    "aws_config_configuration_recorder.main",
    "aws_config_delivery_channel.main",
  ]
}

resource "aws_config_config_rule" "ec2-volume-inuse-check" {
  name        = "ec2-volume-inuse-check"
  description = "Checks whether EBS volumes are attached to EC2 instances"

  source {
    owner             = "AWS"
    source_identifier = "EC2_VOLUME_INUSE_CHECK"
  }

  depends_on = ["aws_config_configuration_recorder.main"]
}

resource "aws_config_config_rule" "instances-in-vpc" {
  name        = "instances-in-vpc"
  description = "Ensure all EC2 instances run in a VPC"

  source {
    owner             = "AWS"
    source_identifier = "INSTANCES_IN_VPC"
  }

  depends_on = [
    "aws_config_configuration_recorder.main",
    "aws_config_delivery_channel.main",
  ]
}

resource "aws_config_config_rule" "eip-attached" {
  name        = "eip-attached"
  description = "Checks whether all Elastic IP addresses that are allocated to a VPC are attached to EC2 instances or in-use elastic network interfaces (ENIs)."

  source {
    owner             = "AWS"
    source_identifier = "EIP_ATTACHED"
  }

  depends_on = [
    "aws_config_configuration_recorder.main",
  ]
}

// Manage Tools
resource "aws_config_config_rule" "cloudtrail-enabled" {
  name        = "cloudtrail-enabled"
  description = "Ensure CloudTrail is enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  maximum_execution_frequency = "${var.config_max_execution_frequency}"

  depends_on = [
    "aws_config_configuration_recorder.main",
    "aws_config_delivery_channel.main",
  ]
}

resource "aws_config_config_rule" "require-tags" {
  name             = "require-tags"
  description      = "Checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas."
  input_parameters = "${data.template_file.aws_config_require_tags.rendered}"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  depends_on = ["aws_config_configuration_recorder.main"]
}

// Security, Identity & Compliance
resource "aws_config_config_rule" "iam-user-no-policies-check" {
  name        = "iam-user-no-policies-check"
  description = "Ensure that none of your IAM users have policies attached. IAM users must inherit permissions from IAM groups or roles."

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }

  depends_on = ["aws_config_configuration_recorder.main"]
}

resource "aws_config_config_rule" "iam-password-policy" {
  name             = "iam-password-policy"
  description      = "Ensure the account password policy for IAM users meets the specified requirements"
  input_parameters = "${data.template_file.aws_config_iam_password_policy.rendered}"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  maximum_execution_frequency = "${var.config_max_execution_frequency}"

  depends_on = [
    "aws_config_configuration_recorder.main",
    "aws_config_delivery_channel.main",
  ]
}

resource "aws_config_config_rule" "acm-certificate-expiration-check" {
  name             = "acm-certificate-expiration-check"
  description      = "Ensures ACM Certificates in your account are marked for expiration within the specified number of days"
  input_parameters = "${data.template_file.aws_config_acm_certificate_expiration.rendered}"

  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }

  maximum_execution_frequency = "${var.config_max_execution_frequency}"

  depends_on = ["aws_config_configuration_recorder.main"]
}

resource "aws_config_config_rule" "root-account-mfa-enabled" {
  name        = "root-account-mfa-enabled"
  description = "Ensure root AWS account has MFA enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  maximum_execution_frequency = "${var.config_max_execution_frequency}"

  depends_on = [
    "aws_config_configuration_recorder.main",
    "aws_config_delivery_channel.main",
  ]
}
