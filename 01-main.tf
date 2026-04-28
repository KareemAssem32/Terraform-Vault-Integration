#========================================================================
# provider "aws" and "vault" configuration for Terraform
#========================================================================   
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.42.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.9.0"

    }
  }
}

provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

provider "vault" {
  address = "<VAULT_ADDR>:8200" # Replace with the address of your Vault server
  skip_child_token = true
}

#========================================================================
# Terraform Configuration for AWS RDS Instance with Vault Integration 
#========================================================================
data "vault_kv_secret_v2" "db" {
  mount = "secret" # Replace with the mount path of your KV secrets engine in Vault
  name  = "database" # Replace with the path to your secret in Vault
}

resource "aws_db_instance" "db" {
  db_name                = "<database-name>"  # Replace with your desired database name
  engine                 = "postgres"
  identifier             = "db2-instance-demo"
  instance_class         = "db.t3.micro"
  publicly_accessible    = true
  allocated_storage      = 20
  username               = "<username>"  # Replace with your desired username
  skip_final_snapshot    = false
  password               = data.vault_kv_secret_v2.db.data["password"] # Fetch the password from Vault
}
