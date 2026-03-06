Readme · MDCopier🏗️ Terraform Azure — Architecture Modulaire Preprod
Architecture Terraform complète pour Azure, conçue pour que main.tf soit le seul fichier à toucher pour déployer ou modifier l'infrastructure.

📁 Structure du projet
terraform-azure-preprod/
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

⚙️ Modules disponibles
ModuleRessources crééesVariable d'activationresource_groupResource Group AzureToujours actifnetworkingVNet, Subnets, NSG, règles SSH/HTTPcreate_networking = truevirtual_machineVM Linux/Windows, NIC, IP publique optionnelle, clé SSH autocreate_vm = truestorageStorage Account, Containers, Lifecycle policycreate_storage = truedatabaseAzure SQL Server, Database, Firewall rulescreate_database = truekeyvaultKey Vault, Secrets, Access policiescreate_keyvault = truemonitoringLog Analytics, Application Insights, Alerte CPUcreate_monitoring = true

🔗 Dépendances entre modules
resource_group ◄─── tous les modules en dépendent
networking     ◄─── virtual_machine (subnet_id)
virtual_machine ──► keyvault (ssh_private_key, managed identity)
database        ──► keyvault (admin_password, connection_string)
virtual_machine ──► monitoring (vm_resource_id pour alertes CPU)
