output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = aws_organizations_organization.primary.arn
}

output "security_ou_name" {
  description = "Name of the Security Organizational Unit"
  value       = aws_organizations_organizational_unit.security_ou.name
}

output "workloads_ou_id" {
  description = "ID of the Workloads Organizational Unit"
  value       = aws_organizations_organizational_unit.workloads_ou.id
}

output "cloudtrail_log_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_log_bucket.bucket
}

output "cloudtrail_trail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.organization_trail.name
}

output "administrators_group_name" {
  description = "Name of the Administrators IAM Group"
  value       = aws_iam_group.administrators.name
}

output "read_only_users_group_name" {
  description = "Name of the ReadOnlyUsers IAM Group"
  value       = aws_iam_group.read_only_users.name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}
