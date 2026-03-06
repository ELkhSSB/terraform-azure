# ============================================
# MODULE MONITORING
# Log Analytics Workspace + Application Insights
# ============================================

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = var.app_insights_type
  tags                = var.tags
}

# Alerte CPU > 80%
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count = var.vm_resource_id != "" ? 1 : 0

  name                = "alert-cpu-high-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_resource_id]
  description         = "CPU usage dépasse 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  tags = var.tags
}
