# 🏗️ Terraform Azure — Architecture Modulaire dev

Architecture Terraform complète pour Azure, conçue pour que `main.tf` soit le **seul fichier à toucher** pour déployer ou modifier l'infrastructure.

---# 🏗️ Terraform Azure dev — Architecture Modulaire

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


## 📁 Structure du projet

```
terraform-azure-dev/
├── main.tf                    ← ✅ Le seul fichier à toucher
├── variables.tf               ← Déclaration de toutes les variables
├── outputs.tf                 ← Sorties safe et sensibles séparées
├── providers.tf               ← Configuration Azure + providers
├── terraform.tfvars           ← Tes valeurs (jamais committé)
├── terraform.tfvars.example   ← Modèle safe à committer
├── .gitignore                 ← Protège les fichiers sensibles
└── modules/
    ├── resource_group/        ← Groupe de ressources (toujours actif)
    ├── networking/            ← VNet + Subnets + NSG
    ├── virtual_machine/       ← VM Linux ou Windows
    ├── storage/               ← Storage Account + Containers
    ├── database/              ← Azure SQL Server + Database
    ├── keyvault/              ← Key Vault + Secrets
    └── monitoring/            ← Log Analytics + Application Insights
```

---

## ⚙️ Modules disponibles

| Module | Ressources créées | Variable d'activation |
|--------|------------------|-----------------------|
| **resource_group** | Resource Group Azure | Toujours actif |
| **networking** | VNet, Subnets, NSG, règles SSH/HTTP | `create_networking = true` |
| **virtual_machine** | VM Linux/Windows, NIC, IP publique optionnelle, clé SSH auto | `create_vm = true` |
| **storage** | Storage Account, Containers, Lifecycle policy | `create_storage = true` |
| **database** | Azure SQL Server, Database, Firewall rules | `create_database = true` |
| **keyvault** | Key Vault, Secrets, Access policies | `create_keyvault = true` |
| **monitoring** | Log Analytics, Application Insights, Alerte CPU | `create_monitoring = true` |

---

## 🔗 Dépendances entre modules

```
resource_group ◄─── tous les modules en dépendent
networking     ◄─── virtual_machine (subnet_id)
virtual_machine ──► keyvault (ssh_private_key, managed identity)
database        ──► keyvault (admin_password, connection_string)
virtual_machine ──► monitoring (vm_resource_id pour alertes CPU)
