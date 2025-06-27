# Outputs the ARN (Amazon Resource Name) of the created Organization.
# Useful for verifying the Organization setup.
output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = aws_organizations_organization.primary.arn
}

# Outputs the Name of the Security OU.
output "security_ou_name" {
  description = "Name of the Security Organizational Unit"
  value       = aws_organizations_organizational_unit.security_ou.name
}

# Outputs the ID of the Workloads OU.
output "workloads_ou_id" {
  description = "ID of the Workloads Organizational Unit"
  value       = aws_organizations_organizational_unit.workloads_ou.id
}

# Outputs the name of the CloudTrail log bucket.
# You'll need this to find the bucket in the S3 console.
output "cloudtrail_log_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_log_bucket.bucket
}

# Outputs the name of the CloudTrail trail.
# Note: Now referencing 'aws_cloudtrail' resource, not 'aws_cloudtrail_trail'.
output "cloudtrail_trail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.organization_trail.name
}

# Outputs the name of the Administrators IAM Group.
output "administrators_group_name" {
  description = "Name of the Administrators IAM Group"
  value       = aws_iam_group.administrators.name
}

# Outputs the name of the ReadOnlyUsers IAM Group.
output "read_only_users_group_name" {
  description = "Name of the ReadOnlyUsers IAM Group"
  value       = aws_iam_group.read_only_users.name
}

# Output the VPC ID from the module
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}
