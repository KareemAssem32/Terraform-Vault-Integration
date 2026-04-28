# 🔐 Securing Terraform – Best Practices Guide

This document outlines practical and production-grade approaches to securely manage sensitive data in Terraform.

---

## 📌 Why This Matters

Terraform state and configuration files may contain sensitive data such as:

* API keys
* Database credentials
* Tokens
* Private keys

If not handled properly, this can lead to **serious security breaches**.

---

## 🧱 1. Use `sensitive` Attribute (Basic Protection)

Terraform allows marking variables and outputs as sensitive.

### Example:

```hcl
variable "aws_access_key_id" {
  type      = string
  sensitive = true
}
```

### Output Example:

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

### ✅ What it does:

* Hides values from CLI output

### ❌ What it does NOT do:

* Does NOT encrypt values in state file

👉 Use this for **UI masking only**, not real security.

---

## 🔐 2. Use a Secrets Manager (Recommended)

Never hardcode secrets in Terraform.

### Supported Options:

* HashiCorp Vault
* AWS Secrets Manager
* AWS SSM Parameter Store

### Example using Vault:

```hcl
data "vault_generic_secret" "aws_creds" {
  path = "secret/data/aws"
}

locals {
  aws_access_key = data.vault_generic_secret.aws_creds.data["access_key"]
  aws_secret_key = data.vault_generic_secret.aws_creds.data["secret_key"]
}
```

### ✅ Benefits:

* Centralized secret management
* Dynamic secrets (Vault)
* Secret rotation support

---

## 🗄️ 3. Secure Remote Backend (Critical)

Terraform state file is **the most sensitive file**.

### ❌ Never:

* Commit `terraform.tfstate` to Git
* Store state locally in production

### ✅ Use Remote Backend (Example: S3)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 🔒 Security Features:

* `encrypt = true` → Enables server-side encryption (SSE)
* DynamoDB → State locking (prevents corruption)

---

## 🌍 4. Use Environment Variables

Avoid writing credentials in `.tf` files.

### Example:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

Terraform automatically reads:

```hcl
provider "aws" {}
```

### ⚠️ Notes:

* Do NOT commit `.env` files
* Use `.gitignore`

---

## 🔑 5. IAM Roles Instead of Static Credentials (Best Practice)

Instead of static credentials, use:

* EC2 Instance Roles
* EKS IAM Roles for Service Accounts (IRSA)

### ✅ Benefits:

* No hardcoded credentials
* Automatic rotation
* Least privilege access

---

## 🧼 6. Avoid Hardcoding Secrets

### ❌ Bad:

```hcl
password = "admin123"
```

### ✅ Good:

```hcl
password = var.db_password
```

---

## 📦 7. Use `.gitignore`

Ensure sensitive files are ignored:

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
.env
```

---

## 🔍 8. Limit Access to State

* Restrict S3 bucket access via IAM
* Enable versioning
* Enable logging

---

## 🔄 9. Rotate Secrets Regularly

* Vault → Dynamic secrets
* AWS → Rotate keys via IAM

---

## 🚨 Common Mistakes

* ❌ Committing `.tfstate` to Git
* ❌ Hardcoding credentials
* ❌ Using root AWS account
* ❌ Sharing Terraform outputs with secrets
* ❌ No state encryption

---

## 🧠 Production-Grade Setup (Recommended Stack)

| Component          | Tool                       |
| ------------------ | -------------------------- |
| Secrets Management | Vault                      |
| State Storage      | S3 + DynamoDB              |
| Auth               | IAM Roles                  |
| CI/CD              | GitHub Actions / GitLab CI |

---

## ✅ Final Takeaways

* `sensitive = true` ≠ security
* State file = **critical asset**
* Vault or Secrets Manager = **must in production**
* Prefer **dynamic credentials over static**
