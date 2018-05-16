Terraform-aws-config
======================
Rule List & Description
--------------------------
The rules are divide into 3 group
### Compute
   1. restricted-ssh
     - Checks whether security groups in use do not allow restricted incoming SSH traffic.
   2. restricted-common-ports
     - Checks whether security groups in use  do not allow restricted incoming TCP traffic to the specified ports.
   3. ec2-volume-inuse-check
     - Checks whether EBS volumes are attached to EC2 instances
   4. instances-in-vpc
     - Ensure all EC2 instances run in a VPC
   5. eip-attached
     - Checks whether all Elastic IP addresses that are allocated to a VPC are attached to EC2 instances or in-use elastic network interfaces (ENIs).
 ### Manage Tools
   1. cloudtrail-enabled
     - Ensure CloudTrail is enabled
   2. require-tags
     - Checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas.
 ### Security, Identity & Compliance
   1. iam-user-no-policies-check
     - Ensure that none of your IAM users have policies attached. IAM users must inherit permissions from IAM groups or roles.
   2. iam-password-policy
     - Ensure the account password policy for IAM users meets the specified requirements
   3. acm-certificate-expiration-check
     - Ensures ACM Certificates in your account are marked for expiration within the specified number of days
   4. root-account-mfa-enabled
     - Ensure root AWS account has MFA enabled

User Guide
----------
### Prerequirement
   - Install AWS CLI
      - [Installing the AWS Command Line Interface](https://docs.aws.amazon.com/zh_tw/cli/latest/userguide/installing.html)
   - Install Terraform
     - [Download Terraform](https://www.terraform.io/downloads.html)
### Adjust the main.auto.tfvars
``` main.auto.tfvars
// AWS INFO (Insert your AWS INFO)
profile = ""                -> insert the aws profile name
assume_role = ""            -> insert the assume role' arn
region = ""                 -> insert the region
config_logs_bucket = ""     -> insert the bucket name you want
// restricted_common_ports  (Classified the port number, example as below)
blockedPort1 = "20"
blockedPort2 = "21"
blockedPort3 = "3389"
blockedPort4 = "3306"
blockedPort5 = "4433"
// require-tags             (Classified the key for your resource,example as below)
tag1Key = "Project-Name"
tag2Key = "Server-Name"
tag3Key = "Owner"
```
### Quick Start
``` initial
terraform init
terraform plan
terraform apply
``` 

Reference Link
--------------
 Further rules for reference
 - AWS Managed Config Rules
     - [managed-rules-by-aws-config](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)
 - AWS Config Rule Repository
     - [awslabs](https://github.com/awslabs/aws-config-rules)