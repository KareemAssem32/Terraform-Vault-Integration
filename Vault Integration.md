# Vault Integration

Here are the detailed steps for setting up HashiCorp Vault and integrating it with Terraform.

---

## ⚠️ Prerequisites & Important Notes

Before starting, make sure of the following:

* ✅ Security Group configuration:

  * Allow **SSH (port 22)** for EC2 access
  * Allow **Vault (port 8200)**
  * Allow **PostgreSQL (port 5432)**

* ⚠️ For testing purposes only:

  * Both the **EC2 instance** and the **database** are deployed in a **public subnet**
  * ❗ This is **NOT a best practice** for production environments

* ✅ Verify credentials:

  * Double-check **database username/password**
  * Ensure Vault configuration matches correct credentials
  * Confirm Terraform variables are correctly set

---

## 🚀 Create an AWS EC2 instance with Ubuntu

* Go to AWS Console → EC2
* Launch Instance
* Select Ubuntu Server
* Choose instance type
* Configure networking & security group
* Launch instance

---

## 📦 Install Vault

```bash
sudo apt update && sudo apt install gpg -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault -y
```

---

## ▶️ Start Vault (Dev Mode)

```bash
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

---

## 🔐 Configure AppRole Authentication

### Enable AppRole

```bash
vault auth enable approle
```

### Create Policy

```bash
vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
```

### Create Role

```bash
vault write auth/approle/role/terraform \
    token_policies=terraform \
    token_ttl=20m
```

### Get Role ID

```bash
vault read auth/approle/role/terraform/role-id
```

### Generate Secret ID

```bash
vault write -f auth/approle/role/terraform/secret-id
```

---

## 🧪 Store a Secret in Vault

```bash
vault kv put secret/myapp username="admin" password="12345678"
```

---

## 🏗️ Terraform Example Configuration

### Provider Configuration

```hcl
provider "vault" {
  address = "http://<VAULT_PUBLIC_IP>:8200"

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "<ROLE_ID>"
      secret_id = "<SECRET_ID>"
    }
  }
}
```

---

### Read Secret from Vault

```hcl
data "vault_kv_secret_v2" "example" {
  mount = "secret"
  name  = "myapp"
}

output "db_username" {
  value = data.vault_kv_secret_v2.example.data["username"]
}

output "db_password" {
  value     = data.vault_kv_secret_v2.example.data["password"]
  sensitive = true
}
```

---

## ▶️ Run Terraform

```bash
terraform init
terraform apply
```

---

## 🛠️ Troubleshooting

### ❌ Error: "A problem has occurred"

* Check Vault logs:

```bash
vault server -dev
```

---

### ❌ Permission Denied

* Verify policy is attached:

```bash
vault token lookup
```

* Check policy:

```bash
vault policy read terraform
```

---

### ❌ Invalid Role ID / Secret ID

* Regenerate Secret ID:

```bash
vault write -f auth/approle/role/terraform/secret-id
```

---

### ❌ Cannot Connect to Vault

* Check Security Group:

  * Port 8200 must be open

* Test connection:

```bash
curl http://<VAULT_PUBLIC_IP>:8200/v1/sys/health
```

---

### ❌ Vault Sealed

```bash
vault status
```

If sealed:

```bash
vault operator unseal
```

---

### ❌ Terraform Authentication Fails

* Ensure:

  * Correct Role ID
  * Correct Secret ID
  * Vault is running
  * AppRole enabled

---

## ✅ Best Practices in Real PROD (Important)

* ❌ Do NOT use dev mode
* ❌ Do NOT expose Vault publicly
* ✅ Use private subnets
* ✅ Rotate secrets regularly
* ✅ Use least privilege policies

---
