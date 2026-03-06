# ⚙️ Setup GitHub Actions — Terraform Azure dev

## Étape 1 — Créer le Service Principal Azure

Un Service Principal = un "compte de service" pour que la pipeline puisse se connecter à Azure sans mot de passe humain.

```bash
# Connexion Azure
az login

# Créer le Service Principal
az ad sp create-for-rbac \
  --name "sp-terraform-dev" \
  --role "Contributor" \
  --scopes "/subscriptions/TON-SUBSCRIPTION-ID" \
  --sdk-auth
```

Tu obtiendras un JSON comme ça — **garde-le précieusement** :
```json
{
  "clientId":       "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",   ← ARM_CLIENT_ID
  "clientSecret":   "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", ← ARM_CLIENT_SECRET
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",   ← ARM_SUBSCRIPTION_ID
  "tenantId":       "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"    ← ARM_TENANT_ID
}
```

---

## Étape 2 — Créer le Storage Account pour le Terraform State

Le "state" = fichier qui mémorise ce qui est déjà déployé sur Azure.

```bash
# Créer le resource group pour le state
az group create \
  --name "rg-terraform-state" \
  --location "francecentral"

# Créer le storage account
az storage account create \
  --name "stterraformstate4821" \
  --resource-group "rg-terraform-state" \
  --location "francecentral" \
  --sku "Standard_LRS"

# Créer le container
az storage container create \
  --name "tfstate" \
  --account-name "stterraformstate4821"
```

---

## Étape 3 — Ajouter les secrets GitHub

Dans ton repo GitHub :
**Settings → Secrets and variables → Actions → New repository secret**

| Nom du secret | Valeur |
|--------------|--------|
| `ARM_CLIENT_ID` | clientId du JSON |
| `ARM_CLIENT_SECRET` | clientSecret du JSON |
| `ARM_SUBSCRIPTION_ID` | subscriptionId du JSON |
| `ARM_TENANT_ID` | tenantId du JSON |
| `TF_STATE_RG` | `rg-terraform-state` |
| `TF_STATE_SA` | `stterraformstate4821` |
| `TF_PROJECT` | nom de ton projet |

---

## Étape 4 — Créer les environnements GitHub

Dans ton repo GitHub :
**Settings → Environments → New environment**

Créer 2 environnements :

### `dev`
- Ajouter une règle **"Required reviewers"** → ton compte GitHub
- Cela bloque l'apply jusqu'à ce que tu approuves manuellement

### `dev-destroy`
- Ajouter une règle **"Required reviewers"** → ton compte GitHub
- Protection supplémentaire avant un destroy

---

## Étape 5 — Activer le backend dans providers.tf

Décommenter le bloc backend dans `providers.tf` :

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "stterraformstate4821"
  container_name       = "tfstate"
  key                  = "dev.terraform.tfstate"
}
```

---

## Étape 6 — Ajouter .gitignore

```bash
# Fichiers à ne JAMAIS commiter
*.tfstate
*.tfstate.backup
*.tfvars          # contient des valeurs sensibles
.terraform/
tfplan
*.pem
```

---

## Flux de travail quotidien

```
Tu modifies main.tf ou terraform.tfvars
            │
            ▼
    git add . && git commit -m "feat: ajout VM"
            │
            ├── git push origin dev
            │         │
            │         ▼
            │    Pipeline : validate + plan
            │    (pas d'apply sur dev)
            │
            └── git push origin main  (ou merge PR)
                      │
                      ▼
                 validate + plan
                      │
                      ▼
              ⏸️ Attente approbation
                      │
                 Tu approuves ✅
                      │
                      ▼
                terraform apply
                   sur Azure
```
