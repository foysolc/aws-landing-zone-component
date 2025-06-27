variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-2" 
}

variable "organization_name" {
  description = "Name for the AWS Organization"
  type        = string
  default     = "FoysolLandingZoneOrg" 
}

variable "cloudtrail_log_bucket_base_name" {
  description = "Base name for the CloudTrail log S3 bucket (will append random string)"
  type        = string
  default     = "foysol-lz-logs-proj-new-unique" 
}

variable "enable_cloudtrail" {
  description = "Set to true to enable CloudTrail. Set to false to disable if experiencing errors."
  type        = bool
  default     = true 
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "The name tag for the VPC"
  type        = string
  default     = "my-landing-zone-vpc" 
}
