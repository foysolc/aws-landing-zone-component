# --- AWS Provider Configuration ---
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# --- AWS Organizations Setup ---
resource "aws_organizations_organization" "primary" {
  aws_service_access_principals = ["cloudtrail.amazonaws.com"]
  feature_set                   = "ALL"
}

# Create Organizational Unit (OU)
resource "aws_organizations_organizational_unit" "security_ou" {
  parent_id = aws_organizations_organization.primary.roots[0].id
  name      = "Security"
}

resource "aws_organizations_organizational_unit" "workloads_ou" {
  parent_id = aws_organizations_organization.primary.roots[0].id
  name      = "Workloads"
}

resource "aws_organizations_organizational_unit" "sandbox_ou" {
  parent_id = aws_organizations_organization.primary.roots[0].id
  name      = "Sandbox"
}

# --- VPC Module Call ---
module "vpc" {
  source = "./modules/vpc"
  name   = var.vpc_name
  cidr   = var.vpc_cidr
}

# --- Centralized CloudTrail Logging Setup ---
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "cloudtrail_log_bucket" {
  bucket        = "${var.cloudtrail_log_bucket_base_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name    = "CloudTrailLogBucket-${var.organization_name}"
    Project = "LandingZone"
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_versioning" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_encryption" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_caller_identity" "current" {}

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
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.cloudtrail_log_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy_doc.json

}

resource "aws_cloudtrail" "organization_trail" {
  name                          = "${var.organization_name}-OrgTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_log_bucket.id
  enable_logging                = true
  include_global_service_events = true

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_bucket_policy
  ]

  tags = {
    Name    = "OrgTrail-${var.organization_name}"
    Project = "LandingZone"
  }
}

# --- Basic IAM Group Structure ---
resource "aws_iam_group" "administrators" {
  name = "Administrators"
}

resource "aws_iam_group_policy_attachment" "administrators_policy_attach" {
  group      = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "read_only_users" {
  name = "ReadOnlyUsers"
}

resource "aws_iam_group_policy_attachment" "read_only_users_policy_attach" {
  group      = aws_iam_group.read_only_users.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}