# 🏗️ Terraform Azure dev — Architecture Modulaire

## 📁 Structure

```
terraform-azure-dev/
├── main.tf              ← ✅ Le seul fichier à toucher
├── variables.tf         ← Déclaration des variables
├── outputs.tf           ← Sorties de tous les modules
├── providers.tf         ← Config Azure provider
├── terraform.tfvars     ← Tes valeurs (à personnaliser)
└── modules/
    ├── resource_group/  ← Groupe de ressources
    ├── networking/      ← VNet + Subnets + NSG
    ├── virtual_machine/ ← VM Linux ou Windows
    ├── storage/         ← Storage Account + Containers
    ├── database/        ← Azure SQL Server + DB
    ├── keyvault/        ← Key Vault + Secrets
    └── monitoring/      ← Log Analytics + App Insights
```

## 🚀 Démarrage rapide

```bash
# 1. Connexion Azure
az login
az account set --subscription "TON-SUBSCRIPTION-ID"

# 2. Init
terraform init

# 3. Voir ce qui va être créé
terraform plan

# 4. Appliquer
terraform apply
```

## ⚙️ Activer un module

Dans `terraform.tfvars`, passe la variable à `true` :

| Module         | Variable             |
|---------------|----------------------|
| Networking     | `create_networking = true` |
| VM             | `create_vm = true`   |
| Storage        | `create_storage = true` |
| Database       | `create_database = true` |
| Key Vault      | `create_keyvault = true` |
| Monitoring     | `create_monitoring = true` |

> 💡 Le **Resource Group** est toujours créé automatiquement.

## 🔗 Dépendances entre modules

```
resource_group ← tous les modules en dépendent
networking     ← virtual_machine en dépend (subnet_id)
virtual_machine ← keyvault (managed identity)
database       ← keyvault (mot de passe stocké)
```

## 🔑 Récupérer les secrets après apply

```bash
# Clé SSH de la VM
terraform output -raw vm_ssh_private_key > vm_key.pem
chmod 400 vm_key.pem
ssh -i vm_key.pem azureuser@<public_ip>

# Mot de passe SQL
terraform output -json database | jq '.admin_password'
```

## 🧹 Destruction

```bash
terraform destroy
```
