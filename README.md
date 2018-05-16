terraform-aws-config
======================
Rule List & Description
--------------------------
The rules are divide into 3 group
### Compute
   - restricted-ssh
    - Checks whether security groups in use do not allow restricted incoming SSH traffic.
   - restricted-common-ports
    - Checks whether security groups in use  do not allow restricted incoming TCP traffic to the specified ports.
   - ec2-volume-inuse-check
    - Checks whether EBS volumes are attached to EC2 instances
   - instances-in-vpc
    - Ensure all EC2 instances run in a VPC
   - eip-attached
    - Checks whether all Elastic IP addresses that are allocated to a VPC are attached to EC2 instances or in-use elastic network interfaces (ENIs).
 ### Manage Tools
   - cloudtrail-enabled
    - Ensure CloudTrail is enabled
   - require-tags
    - Checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas.
 ### Security, Identity & Compliance
   - iam-user-no-policies-check
    - Ensure that none of your IAM users have policies attached. IAM users must inherit permissions from IAM groups or roles.
   - iam-password-policy
    - Ensure the account password policy for IAM users meets the specified requirements
   - acm-certificate-expiration-check
    - Ensures ACM Certificates in your account are marked for expiration within the specified number of days
   - root-account-mfa-enabled
    - Ensure root AWS account has MFA enabled
User Guide
----------
### Prerequirement
   - Install AWS CLI
    - [Installing the AWS Command Line Interface] (https://docs.aws.amazon.com/zh_tw/cli/latest/userguide/installing.html)
   - Install Terraform
    - [Download Terraform] (https://www.terraform.io/downloads.html)
### 

Reference Link
--------------
 Further rules for reference
 - AWS Managed Config Rules
    - [managed-rules-by-aws-config] (https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)
 - AWS Config Rule Repository
    - [awslabs] (https://github.com/awslabs/aws-config-rules)