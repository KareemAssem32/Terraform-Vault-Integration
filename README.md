# Vault + Terraform AWS RDS Integration

This repository demonstrates how to integrate HashiCorp Vault with Terraform to provision an AWS RDS PostgreSQL instance while keeping database credentials secure.

## Overview

The project includes:

- `01-main.tf`: Terraform configuration to deploy an AWS RDS PostgreSQL instance.
- `Vault Integration.md`: Step-by-step Vault setup and Terraform Vault authentication guidance.
- `Terraform Security.md`: Best practices for securing Terraform, handling secrets, and protecting state.
- `db.sh`: Example PostgreSQL connection and SQL commands for validating the created database.

## What This Project Does

The Terraform configuration uses both the `aws` and `vault` providers.
- AWS provider configures the target AWS region.
- Vault provider is configured to read secrets from a Vault KV store.
- The PostgreSQL password for the RDS instance is retrieved from Vault using `data.vault_kv_secret_v2`.

## Setup and Usage

1. Install Terraform and AWS CLI.
2. Prepare Vault:
   - Deploy Vault locally or in your environment.
   - Enable the KV secrets engine.
   - Store database credentials under a Vault secret path.
3. Update `01-main.tf` with your AWS region, Vault address, database name, and username.
4. Run Terraform:

```bash
terraform init
terraform apply
```

5. After deployment, use `db.sh` as a template to connect to the database and execute SQL queries.

## Vault Integration Notes

The Vault integration is intended to demonstrate how to keep sensitive data, such as database passwords, out of Terraform source files and state as much as possible.
- Use Vault policies and AppRole authentication in production.
- Avoid hardcoding secrets in Terraform and do not commit `.tfstate` files.

## Security Guidance

Refer to `Terraform Security.md` for important security practices:
- Use sensitive variables and outputs.
- Store secrets in Vault or another secrets manager.
- Use a remote backend for Terraform state.
- Avoid committing credentials or state files to version control.
- Use IAM roles instead of static credentials when possible.

## Important Warnings

- The sample Vault integration shown in this repository is primarily for learning and testing.
- Do not deploy this exact setup into production without applying secure networking, least privilege, and Vault authentication hardening.

## Files

- `01-main.tf`: Main Terraform configuration.
- `Vault Integration.md`: Vault setup guide and examples.
- `Terraform Security.md`: Best practices for Terraform security.
- `db.sh`: Shell command examples for connecting to PostgreSQL and managing data.

## License

This project does not include a license file. Use it for learning and adapt it to your own environment.
