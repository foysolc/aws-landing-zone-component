# 🚀 Basic AWS Landing Zone Component with Terraform

This repository contains Infrastructure as Code (IaC) for deploying a foundational, secure, and organised AWS environment. This project serves as a baseline for deploying future workloads in a well-architected way, emphasising a multi-account strategy, centralised logging, and secure access management.

---

## ✨ Project Overview

A "Landing Zone" is a meticulously configured, secure, and scalable AWS environment that serves as the starting point for your cloud operations. This project automates the deployment of essential foundational components, providing a robust and compliant base for any AWS workload.

**This setup demonstrates:**

* **Centralised Multi-Account Management:** Using AWS Organisations to structure accounts.

* **Secure Logging:** Centralising audit logs for security and compliance.

* **Identity Management:** Setting up foundational IAM groups.

* **Network Foundation:** Deploying a dedicated Virtual Private Cloud (VPC).

---

## 🌟 Key Features & Technologies

* **Infrastructure as Code (IaC):** Defined and managed entirely using [Terraform](https://www.terraform.io/).

* **AWS Organisations:** Establishes a master account, root, and foundational Organisational Units (OUs) for logical account grouping (`Security`, `Workloads`, `Sandbox`).

* **Centralised CloudTrail Logging:** Configures a multi-region CloudTrail to capture and deliver API activity from all accounts within the Organisation to a dedicated, secure [Amazon S3](https://aws.amazon.com/s3/) bucket.

    * S3 bucket with versioning and server-side encryption (AES256).

    * Strict bucket policy to allow only CloudTrail write access.

* **Foundational Networking:** Deploys a dedicated [Amazon VPC](https://aws.amazon.com/vpc/) using a Terraform module for isolated network resources.

* **Basic IAM Structure:** Creates essential [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/) groups (`Administrators`, `ReadOnlyUsers`) with attached AWS-managed policies for simplified user management.

---

## 🌐 Architecture Overview

This project sets up the core management and foundational layers within an AWS account:

```text
+-------------------------------------------------------+
|                 AWS Master Account                    |
| +---------------------------------------------------+ |
| |               AWS Organisations                   | |
| | +-----------------------------------------------+ | |
| | |                  Root                         | | |
| | | +-----------+ +------------+ +------------+ | | |
| | | | Security  | |  Workloads | |  Sandbox   | | | |
| | | |   (OU)    | |    (OU)    | |    (OU)    | | | |
| | | +-----------+ +------------+ +------------+ | | |
| | +-----------------------------------------------+ | |
+---------------------------------------------------+ |
|                                                       |
| +---------------------------------------------------+ |
| |              Centralised Logging                  | |
| | +---------------------+     +-----------------+   | |
| | |  CloudTrail Trail   | --> | S3 Log Bucket   |   | |
| | | (Organisation-wide) |     | (Versioned, Enc.) |   | |
| | +---------------------+     +-----------------+   | |
+---------------------------------------------------+ |
|                                                       |
| +---------------------------------------------------+ |
| |                IAM Groups                         | |
| | +---------------+    +----------------+         | |
| | | Administrators|    | ReadOnlyUsers  |         | |
| | +---------------+    +----------------+         | |
+---------------------------------------------------+ |
|                                                       |
| +---------------------------------------------------+ |
| |                Core VPC Network                   | |
| | +-----------------------------------------------+ | |
| | |      VPC (10.0.0.0/16)                        | | |
| | | (via ./modules/vpc)                           | | |
| | +-----------------------------------------------+ | |
+-------------------------------------------------------+
```

* **AWS Organisations:** Provides the hierarchical structure to manage multiple AWS accounts.

* **CloudTrail:** Records and delivers API activity for audit and security purposes.

* **S3 Log Bucket:** Securely stores all CloudTrail logs.

* **IAM Groups:** Predefined groups for common permission sets.

* **VPC:** A dedicated virtual network isolated within AWS.

---

## 🚀 Deployment Steps

Follow these steps to deploy your basic AWS Landing Zone foundation using this Terraform configuration.

### 🔧 Prerequisites

* An AWS Account.

* [**AWS CLI**](https://aws.amazon.com/cli/) installed and configured with appropriate credentials.

* [**Terraform**](https://www.terraform.io/downloads.html) installed (version 1.0+ recommended).

### ⚙️ Setup and Deployment

#### 1. Clone the Repository:

```bash
git clone [https://github.com/your-github-username/aws-landing-zone-terraform.git](https://github.com/your-github-username/aws-landing-zone-terraform.git)
cd aws-landing-zone-terraform
```

*(Remember to replace `your-github-username` and `aws-landing-zone-terraform` with your actual GitHub details).*

#### 2. Customise Variables:

Open `variables.tf` and/or `terraform.tfvars` (if you created one) and **customise the `default` values** for these critical variables to ensure global uniqueness and reflect your setup:

* `organisation_name`: e.g., `YourNameLandingZoneOrg` (must be unique).

* `cloudtrail_log_bucket_base_name`: e.g., `yourname-lz-logs-unique-suffix` (must be globally unique for S3).

* `aws_region`: Ensure this is your desired region (e.g., `eu-west-2`).

* `vpc_name` and `vpc_cidr` can be customised as well.

#### 3. Initialise Terraform:

Navigate to the root of your project directory (where `main.tf` is located) and initialise Terraform. This downloads necessary AWS provider plugins and prepares your working directory.

```bash
terraform init -reconfigure
```

#### 4. Review the Deployment Plan:

Generate an execution plan to see exactly what resources Terraform will create, modify, or destroy in your AWS account. This is a crucial safety step.

```bash
terraform plan
```

*Expect to see a summary indicating new resources will be added (especially AWS Organisation and OUs on the first run).*

#### 5. Apply the Configuration:

Execute the plan to provision the AWS infrastructure. This step will prompt for confirmation (`yes`).

```bash
terraform apply
```

* **Important Note:** This step will create your AWS Organisation (if one doesn't exist), OUs, VPC, S3 bucket, and CloudTrail. It may take a few minutes for all resources to become active.

#### 6. Verify Deployment (AWS Console):

After `terraform apply` completes successfully, log into your AWS Management Console and visually confirm the creation of:

* **AWS Organisations:** Check for the created OUs (`Security`, `Workloads`, `Sandbox`).

* **Amazon S3:** Locate your CloudTrail log bucket (with the unique suffix). Verify versioning and encryption settings.

* **AWS CloudTrail:** Confirm the `*-OrgTrail` is active and logging to your S3 bucket.

* **Amazon VPC:** Verify your `my-landing-zone-vpc` (or custom name) is present with the specified CIDR.

* **AWS IAM > User Groups:** Confirm `Administrators` and `ReadOnlyUsers` groups exist with their attached policies.

### Cleanup (Optional)

To tear down all the AWS resources created by this project and avoid incurring further charges:

#### 1. Empty the CloudTrail S3 Bucket (Crucial!):

S3 buckets cannot be deleted by Terraform if they contain objects (logs). You must empty it first. Replace `YOUR_CLOUDTRAIL_LOG_BUCKET_NAME` with the exact bucket name from your `terraform apply` output or the S3 console.

```bash
aws s3 rm s3://YOUR_CLOUDTRAIL_LOG_BUCKET_NAME --recursive
```

#### 2. Destroy Terraform Resources:

```bash
terraform destroy
```

* This will ask for confirmation (`yes`). Be absolutely sure you want to delete all associated resources before proceeding.

---

## 📁 Project Structure

```text
.
├── main.tf                 # Main Terraform configuration for the landing zone components.
├── variables.tf            # Input variables for configuration (region, org name, bucket names, VPC).
├── outputs.tf              # Outputs from Terraform (e.g., Organisation ARN, OU IDs, bucket name).
├── versions.tf             # Specifies required Terraform and provider versions.
├── modules/                # Directory for reusable Terraform modules.
│   └── vpc/                # VPC module for consistent network deployment.
│       ├── main.tf         # Defines the VPC resource for the module.
│       └── variables.tf    # Variables specific to the VPC module.
└── terraform.tfvars        # (Optional) Override default variable values here.
├── README.md               # This file.
└── .gitignore              # Specifies files to ignore in Git (e.g., .terraform/, *.tfstate).
```

---

## 🧠 Key Learnings & Interview Highlights

This project provides hands-on experience with fundamental cloud concepts and tools, making it an excellent talking point for technical interviews:

* **Foundational Cloud Setup & Governance:**

    * "This project allowed me to implement core governance principles in AWS by setting up a **basic landing zone component**. This involved creating **AWS Organisational Units (OUs)** to enable a multi-account strategy, which is critical for **security, cost management, and resource isolation** in a growing cloud environment."

* **Centralised Logging for Security & Auditing:**

    * "I configured **AWS CloudTrail** to centralise API activity logging from my AWS Organisation into a dedicated and secure **Amazon S3 bucket**. This ensures comprehensive auditing capabilities, which are vital for **security monitoring, compliance, and troubleshooting** operational issues."

* **Identity and Access Management (IAM) Best Practises:**

    * "I established a foundational **IAM group structure** by creating 'Administrators' and 'ReadOnlyUsers' groups, and attaching appropriate AWS-managed policies. This demonstrates the implementation of the **principle of least privilege**, ensuring users only have the permissions necessary for their roles."

* **Infrastructure as Code (IaC) for Foundational Components:**

    * "Building on my previous experience, I used **Terraform** to automate the deployment of these landing zone components. This reinforced my ability to define, deploy, and manage complex cloud infrastructure through code, ensuring **repeatability, consistency, and efficient version control** of the AWS environment."

* **Understanding Core AWS Services for Operations:**

    * "This project deepened my understanding of how fundamental AWS services like **Organisations, S3, CloudTrail, and IAM** work together to create a secure and well-managed cloud environment, moving beyond simple application deployment to operational foundations."

* **Problem-Solving & Attention to Detail:**

    * "I practised meticulous configuration, especially concerning S3 bucket naming uniqueness, bucket policies for cross-service access (CloudTrail writing to S3), and understanding regional nuances for services like Organisations. I also debugged persistent `terraform validate` errors, adapting the code to use a working CloudTrail resource when `aws_cloudtrail_trail` caused issues and resolving S3 ACL conflicts."

---

## 📄 Licence

This project is open-sourced under the [MIT Licence](LICENSE).
