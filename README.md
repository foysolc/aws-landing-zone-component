🚀 Basic AWS Landing Zone Component with Terraform

This repository contains Infrastructure as Code (IaC) for deploying a foundational, secure, and organized AWS environment. This project serves as a baseline for deploying future workloads in a well-architected way, emphasizing a multi-account strategy, centralized logging, and secure access management.

✨ Project Overview

A "Landing Zone" is a meticulously configured, secure, and scalable AWS environment that serves as the starting point for your cloud operations. This project automates the deployment of essential foundational components, providing a robust and compliant base for any AWS workload.

This setup demonstrates:

Centralized Multi-Account Management: Using AWS Organizations to structure accounts.

Secure Logging: Centralizing audit logs for security and compliance.

Identity Management: Setting up foundational IAM groups.

Network Foundation: Deploying a dedicated Virtual Private Cloud (VPC).

🌟 Key Features & Technologies
Infrastructure as Code (IaC): Defined and managed entirely using Terraform.

AWS Organizations: Establishes a master account, root, and foundational Organizational Units (OUs) for logical account grouping (Security, Workloads, Sandbox).

Centralized CloudTrail Logging: Configures a multi-region CloudTrail to capture and deliver API activity from all accounts within the Organization to a dedicated, secure Amazon S3 bucket.

S3 bucket with versioning and server-side encryption (AES256).

Strict bucket policy to allow only CloudTrail write access.

Foundational Networking: Deploys a dedicated Amazon VPC using a Terraform module for isolated network resources.

Basic IAM Structure: Creates essential AWS Identity and Access Management (IAM) groups (Administrators, ReadOnlyUsers) with attached AWS-managed policies for simplified user management.

🌐 Architecture Overview
This project sets up the core management and foundational layers within an AWS account:

+-------------------------------------------------------+
|                 AWS Master Account                    |
| +---------------------------------------------------+ |
| |               AWS Organizations                   | |
| | +-----------------------------------------------+ | |
| | |                  Root                         | | |
| | | +-----------+ +------------+ +------------+ | | |
| | | | Security  | |  Workloads | |  Sandbox   | | | |
| | | |   (OU)    | |    (OU)    | |    (OU)    | | | |
| | | +-----------+ +------------+ +------------+ | | |
| | +-----------------------------------------------+ | |
| +---------------------------------------------------+ |
|                                                       |
| +---------------------------------------------------+ |
| |              Centralized Logging                  | |
| | +---------------------+     +-----------------+   | |
| | |  CloudTrail Trail   | --> | S3 Log Bucket   |   | |
| | | (Organization-wide) |     | (Versioned, Enc.) |   | |
| | +---------------------+     +-----------------+   | |
| +---------------------------------------------------+ |
|                                                       |
| +---------------------------------------------------+ |
| |                IAM Groups                         | |
| | +---------------+    +----------------+         | |
| | | Administrators|    | ReadOnlyUsers  |         | |
| | +---------------+    +----------------+         | |
| +---------------------------------------------------+ |
|                                                       |
| +---------------------------------------------------+ |
| |                Core VPC Network                   | |
| | +-----------------------------------------------+ | |
| | |      VPC (10.0.0.0/16)                        | | |
| | | (via ./modules/vpc)                           | | |
| | +-----------------------------------------------+ | |
| +---------------------------------------------------+ |
+-------------------------------------------------------+

AWS Organizations: Provides the hierarchical structure to manage multiple AWS accounts.

CloudTrail: Records and delivers API activity for audit and security purposes.

S3 Log Bucket: Securely stores all CloudTrail logs.

IAM Groups: Predefined groups for common permission sets.

VPC: A dedicated virtual network isolated within AWS.

🚀 Deployment Steps
Follow these steps to deploy your basic AWS Landing Zone foundation using this Terraform configuration.

Prerequisites
An AWS Account with sufficient permissions to create:

AWS Organizations: Your AWS account must be able to create or manage an Organization. This is typically done from a single "master" or "management" account.

Amazon S3 Buckets, Policies, Versioning, Encryption.

AWS CloudTrail.

AWS IAM Groups and Policy Attachments.

Amazon VPC.

AWS CLI installed and configured with appropriate credentials.

Terraform installed (version 1.0+ recommended).

Setup and Deployment
Clone the Repository:

git clone https://github.com/your-github-username/aws-landing-zone-terraform.git
cd aws-landing-zone-terraform

(Remember to replace your-github-username and aws-landing-zone-terraform with your actual GitHub details).

Configure Variables:
Open variables.tf and/or terraform.tfvars (if you created one) and customize the default values for these critical variables to ensure global uniqueness and reflect your setup:

organization_name: e.g., YourNameLandingZoneOrg (must be unique).

cloudtrail_log_bucket_base_name: e.g., yourname-lz-logs-unique-suffix (must be globally unique for S3).

aws_region: Ensure this is your desired region (e.g., eu-west-2).

vpc_name and vpc_cidr can be customized as well.

Initialize Terraform:
Navigate to the root of your project directory (where main.tf is located) and initialize Terraform. This downloads necessary AWS provider plugins and prepares your working directory.

terraform init -reconfigure

Review the Deployment Plan:
Generate an execution plan to see exactly what resources Terraform will create, modify, or destroy in your AWS account. This is a crucial safety step.

terraform plan

Expect to see a summary indicating new resources will be added (especially AWS Organization and OUs on the first run).

Apply the Configuration:
Execute the plan to provision the AWS infrastructure. This step will prompt for confirmation (yes).

terraform apply

Important Note: This step will create your AWS Organization (if one doesn't exist), OUs, VPC, S3 bucket, and CloudTrail. It may take a few minutes for all resources to become active.

Verify Deployment (AWS Console):
After terraform apply completes successfully, log into your AWS Management Console and visually confirm the creation of:

AWS Organizations: Check for the created OUs (Security, Workloads, Sandbox).

Amazon S3: Locate your CloudTrail log bucket (with the unique suffix). Verify versioning and encryption settings.

AWS CloudTrail: Confirm the *-OrgTrail is active and logging to your S3 bucket.

Amazon VPC: Verify your my-landing-zone-vpc (or custom name) is present with the specified CIDR.

AWS IAM > User Groups: Confirm Administrators and ReadOnlyUsers groups exist with their attached policies.

Cleanup (Optional)
To tear down all the AWS resources created by this project and avoid incurring further charges:

Empty the CloudTrail S3 Bucket (Crucial!):
S3 buckets cannot be deleted by Terraform if they contain objects (logs). You must empty it first. Replace YOUR_CLOUDTRAIL_LOG_BUCKET_NAME with the exact bucket name from your terraform apply output or the S3 console.

aws s3 rm s3://YOUR_CLOUDTRAIL_LOG_BUCKET_NAME --recursive

Destroy Terraform Resources:

terraform destroy

This will ask for confirmation (yes). Be absolutely sure you want to delete all associated resources before proceeding.

📁 Project Structure
.
├── main.tf                 # Main Terraform configuration for the landing zone components.
├── variables.tf            # Input variables for configuration (region, org name, bucket names, VPC).
├── outputs.tf              # Outputs from Terraform (e.g., Organization ARN, OU IDs, bucket name).
├── versions.tf             # Specifies required Terraform and provider versions.
├── modules/                # Directory for reusable Terraform modules.
│   └── vpc/                # VPC module for consistent network deployment.
│       ├── main.tf         # Defines the VPC resource for the module.
│       └── variables.tf    # Variables specific to the VPC module.
└── terraform.tfvars        # (Optional) Override default variable values here.
├── README.md               # This file.
└── .gitignore              # Specifies files to ignore in Git (e.g., .terraform/, *.tfstate).

🧠 Key Learnings & Interview Highlights
This project provides hands-on experience with fundamental cloud concepts and tools, making it an excellent talking point for technical interviews:

Foundational Cloud Setup & Governance:

"This project allowed me to implement core governance principles in AWS by setting up a basic landing zone component. This involved creating AWS Organizational Units (OUs) to enable a multi-account strategy, which is critical for security, cost management, and resource isolation in a growing cloud environment."

Centralized Logging for Security & Auditing:

"I configured AWS CloudTrail to centralize API activity logging from my AWS Organization into a dedicated and secure Amazon S3 bucket. This ensures comprehensive auditing capabilities, which are vital for security monitoring, compliance, and troubleshooting operational issues."

Identity and Access Management (IAM) Best Practices:

"I established a foundational IAM group structure by creating 'Administrators' and 'ReadOnlyUsers' groups, and attaching appropriate AWS-managed policies. This demonstrates the implementation of the principle of least privilege, ensuring users only have the permissions necessary for their roles."

Infrastructure as Code (IaC) for Foundational Components:

"Building on my previous experience, I used Terraform to automate the deployment of these landing zone components. This reinforced my ability to define, deploy, and manage complex cloud infrastructure through code, ensuring repeatability, consistency, and efficient version control of the AWS environment."

Understanding Core AWS Services for Operations:

"This project deepened my understanding of how fundamental AWS services like Organizations, S3, CloudTrail, and IAM work together to create a secure and well-managed cloud environment, moving beyond simple application deployment to operational foundations."

Problem-Solving & Attention to Detail:

"I practiced meticulous configuration, especially concerning S3 bucket naming uniqueness, bucket policies for cross-service access (CloudTrail writing to S3), and understanding regional nuances for services like Organizations. I also debugged persistent terraform validate errors, adapting the code to use a working CloudTrail resource when aws_cloudtrail_trail caused issues and resolving S3 ACL conflicts."

📄 License
This project is open-sourced under the MIT License.