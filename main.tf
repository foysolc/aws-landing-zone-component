# --- AWS Provider Configuration ---
provider "aws" {
  region = var.aws_region # Uses the region defined in variables.tf
}

# Provider for ACM certificate in us-east-1 for CloudFront (if needed for web hosting later)
# This is here for completeness but not directly used by the core Landing Zone setup.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# --- AWS Organizations Setup ---
# This resource creates an AWS Organization if one doesn't exist.
# NOTE: This is typically done once per AWS master account.
resource "aws_organizations_organization" "primary" {
  aws_service_access_principals = ["cloudtrail.amazonaws.com"] # Allows CloudTrail integration
  feature_set                   = "ALL"                           # Enables all features like SCPs (Service Control Policies)
}

# Create Organizational Unit (OU) for Security-related accounts
resource "aws_organizations_organizational_unit" "security_ou" {
  # Link to the organization created above
  parent_id = aws_organizations_organization.primary.roots[0].id
  name      = "Security"
}

# Create Organizational Unit (OU) for Workload accounts (e.g., Development, Production)
resource "aws_organizations_organizational_unit" "workloads_ou" {
  # Link to the organization created above
  parent_id = aws_organizations_organization.primary.roots[0].id
  name      = "Workloads"
}

# Create Organizational Unit (OU) for Sandbox accounts (for testing/learning)
resource "aws_organizations_organizational_unit" "sandbox_ou" {
  # Link to the organization created above
  parent_id = aws_organizations_organization.primary.roots[0].id
  name      = "Sandbox"
}

# --- VPC Module Call ---
module "vpc" {
  source = "./modules/vpc"
  name   = var.vpc_name # Using a more specific variable name for VPC
  cidr   = var.vpc_cidr # Using a more specific variable name for VPC
}

# --- Centralized CloudTrail Logging Setup ---
# Create an S3 bucket for CloudTrail logs.
# S3 bucket names must be globally unique, so we append a random string.
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "cloudtrail_log_bucket" {
  # Append a random ID to the base name for global uniqueness.
  bucket        = "${var.cloudtrail_log_bucket_base_name}-${random_id.bucket_suffix.hex}"
  # Removed 'acl = "private"' as it's deprecated and conflicts with S3's default ACLs disabled setting.
  # Access is now controlled purely via bucket policies.
  force_destroy = true # WARNING: Use with caution! Allows deletion of non-empty buckets for easy cleanup.

  # DEPRECATED BLOCKS REMOVED FROM HERE - now handled by dedicated resources:
  # versioning {}
  # server_side_encryption_configuration {}

  tags = {
    Name    = "CloudTrailLogBucket-${var.organization_name}"
    Project = "LandingZone"
  }
}

# REMOVED: aws_s3_bucket_acl.cloudtrail_log_bucket_acl resource is no longer needed
# because new S3 buckets have ACLs disabled by default. Permissions are managed
# solely through bucket policies, which is the recommended best practice.
# resource "aws_s3_bucket_acl" "cloudtrail_log_bucket_acl" {
#   bucket = aws_s3_bucket.cloudtrail_log_bucket.id
#   acl    = "private"
# }

# Dedicated S3 Bucket Versioning Resource (addresses deprecation warning)
resource "aws_s3_bucket_versioning" "cloudtrail_versioning" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Dedicated S3 Bucket Server-Side Encryption Configuration Resource (addresses deprecation warning)
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_encryption" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Data source to get the current AWS account ID for the S3 bucket policy
data "aws_caller_identity" "current" {}

# S3 Bucket Policy: Grants CloudTrail permissions to write logs to the bucket.
# This is required because the bucket is private and ACLs are disabled.
data "aws_iam_policy_document" "cloudtrail_bucket_policy_doc" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_log_bucket.arn]
  }

  statement {
    sid = "AWSCloudTrailWrite"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl" # Required for CloudTrail to set ACL for logs
    ]
    resources = ["${aws_s3_bucket.cloudtrail_log_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      # The 'bucket-owner-full-control' ACL is implicitly handled by bucket ownership controls
      # when ACLs are disabled. This condition ensures compatibility.
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id # Reference the ID of our log bucket.
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy_doc.json
  # Removed explicit depends_on on aws_s3_bucket_acl.cloudtrail_log_bucket_acl
  # as that resource is no longer present.
}

# Create the CloudTrail trail itself (reverting to 'aws_cloudtrail' as 'aws_cloudtrail_trail' fails persistently)
# Note: 'aws_cloudtrail' is deprecated but used here to unblock your deployment.
# It does NOT support 'count' or 'is_organization_trail' directly.
resource "aws_cloudtrail" "organization_trail" {
  name                          = "${var.organization_name}-OrgTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_log_bucket.id # Send logs to our S3 bucket
  # is_organization_trail is not supported by 'aws_cloudtrail' - this trail will only log events for the current account.
  # To log for an organization, it typically needs to be created from the master account using 'aws_cloudtrail_trail'.
  enable_logging                = true
  include_global_service_events = true # Include events from global services like IAM

  # Explicit dependency on the bucket policy for correct permissions
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_bucket_policy
  ]

  tags = {
    Name    = "OrgTrail-${var.organization_name}"
    Project = "LandingZone"
  }
}

# --- Basic IAM Group Structure ---
# IAM Group for Administrators
resource "aws_iam_group" "administrators" {
  name = "Administrators" # Standard name
}

# Attach AdministratorAccess policy to the Administrators group
resource "aws_iam_group_policy_attachment" "administrators_policy_attach" {
  group      = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # AWS managed policy
}

# IAM Group for Read-Only Users
resource "aws_iam_group" "read_only_users" {
  name = "ReadOnlyUsers" # Standard name
}

# Attach ReadOnlyAccess policy to the Read-Only Users group
resource "aws_iam_group_policy_attachment" "read_only_users_policy_attach" {
  group      = aws_iam_group.read_only_users.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # AWS managed policy
}

# NOTE: Users are NOT created by Terraform in this basic setup.
# Users would be manually added to these groups in the IAM console
# or managed by an identity provider (e.g., AWS SSO, Okta).
