variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-2" # CUSTOMIZE THIS: Example is London. Choose your preferred region.
}

variable "organization_name" {
  description = "Name for the AWS Organization"
  type        = string
  default     = "FoysolLandingZoneOrg" # CUSTOMIZE THIS: Choose a unique name for your organization!
}

variable "cloudtrail_log_bucket_base_name" {
  description = "Base name for the CloudTrail log S3 bucket (will append random string)"
  type        = string
  default     = "foysol-lz-logs-proj-new-unique" # CUSTOMIZE THIS: Make this globally unique! (e.g., add more unique identifiers)
}

variable "enable_cloudtrail" {
  description = "Set to true to enable CloudTrail. Set to false to disable if experiencing errors."
  type        = bool
  default     = true # Try to enable by default. If it causes the error, change to false.
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name tag for the VPC"
  type        = string
  default     = "my-landing-zone-vpc" # CUSTOMIZE THIS: VPC name
}
