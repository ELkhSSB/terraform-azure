# 🏗️ Infrastructure Azure avec Terraform — Architecture Modulaire

Mise en place d'une infrastructure cloud automatisée sur **Microsoft Azure** avec **Terraform**, selon les principes de l'**Infrastructure as Code (IaC)**. L'architecture est modulaire : chaque composant peut être activé ou désactivé indépendamment, et l'état de l'infrastructure est géré de manière centralisée et sécurisée.

![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft-Azure-0078D4?logo=microsoftazure&logoColor=white)

---

## 📌 Objectifs

- Automatiser le déploiement d'une infrastructure Azure de manière reproductible
- Structurer le code en modules réutilisables
- Sécuriser les secrets avec Azure Key Vault
- Mettre en place la supervision des ressources déployées

---

## 🧩 Modules disponibles

| Module | Ressources déployées | Variable d'activation |
|--------|----------------------|-----------------------|
| `resource_group` | Groupe de ressources (toujours créé) | — |
| `networking` | Réseau virtuel (VNet), sous-réseaux, NSG | `create_networking` |
| `virtual_machine` | Machine virtuelle Linux ou Windows | `create_vm` |
| `storage` | Compte de stockage et conteneurs | `create_storage` |
| `database` | Serveur Azure SQL et base de données | `create_database` |
| `keyvault` | Key Vault et secrets | `create_keyvault` |
| `monitoring` | Log Analytics et Application Insights | `create_monitoring` |

---

## 📁 Structure du projet

```
terraform-azure/
├── main.tf              # Point d'entrée : appel des modules
├── variables.tf         # Déclaration des variables
├── outputs.tf           # Sorties de tous les modules
├── providers.tf         # Configuration du provider Azure
├── terraform.tfvars     # Valeurs des variables (à personnaliser)
└── modules/
    ├── resource_group/
    ├── networking/
    ├── virtual_machine/
    ├── storage/
    ├── database/
    ├── keyvault/
    └── monitoring/
```

---

## 🔗 Dépendances entre modules

```
resource_group  ←  tous les modules en dépendent
networking      ←  virtual_machine en dépend (subnet_id)
virtual_machine ←  keyvault (identité managée)
database        ←  keyvault (stockage du mot de passe)
```

---

## ✅ Prérequis

- Un abonnement **Microsoft Azure** actif
- [Terraform](https://developer.hashicorp.com/terraform/install) installé
- [Azure CLI](https://learn.microsoft.com/fr-fr/cli/azure/install-azure-cli) installé
- (Optionnel) `jq` pour lire les sorties JSON

---

## 🚀 Démarrage rapide

### 1. Se connecter à Azure

```bash
az login
az account set --subscription "<ID_DE_VOTRE_ABONNEMENT>"
```

### 2. Initialiser Terraform

```bash
terraform init
```

### 3. Visualiser les changements prévus

```bash
terraform plan
```

### 4. Appliquer la configuration

```bash
terraform apply
```

---

## ⚙️ Configuration

Les modules s'activent depuis le fichier `terraform.tfvars` en passant la variable correspondante à `true` :

```hcl
create_networking = true
create_vm         = true
create_storage    = true
create_database   = false
create_keyvault   = true
create_monitoring = true
```

> 💡 Le **Resource Group** est toujours créé automatiquement.

---

## 🔑 Récupération des secrets après déploiement

**Clé SSH de la machine virtuelle :**

```bash
terraform output -raw vm_ssh_private_key > vm_key.pem
chmod 400 vm_key.pem
ssh -i vm_key.pem azureuser@<ADRESSE_IP_PUBLIQUE>
```

**Mot de passe de la base de données :**

```bash
terraform output -json database | jq '.admin_password'
```

---

## 🔒 Bonnes pratiques de sécurité

- Ne jamais versionner les fichiers `*.tfstate`, les clés `.pem` ni les valeurs sensibles
- Ajouter ces éléments au fichier `.gitignore` :

```
.terraform/
*.tfstate
*.tfstate.*
*.pem
```

- Stocker les secrets dans **Azure Key Vault** plutôt qu'en clair
- Utiliser un état distant (remote state) pour partager l'état Terraform de façon sécurisée

---

## 🧹 Suppression de l'infrastructure

Pour détruire toutes les ressources créées et éviter des coûts inutiles :

```bash
terraform destroy
```

---

## 🛠️ Technologies utilisées

- **Terraform** — Infrastructure as Code
- **Microsoft Azure** — Cloud provider
- **Azure CLI** — Authentification et gestion
- **Azure Key Vault** — Gestion des secrets
- **Log Analytics / Application Insights** — Supervision

---

## 👤 Auteur

**Salma EL KHALFI** — Diplômée Master Big Data & Cloud Computing

[![GitHub](https://img.shields.io/badge/GitHub-ELkhSSB-181717?logo=github)](https://github.com/ELkhSSB)
