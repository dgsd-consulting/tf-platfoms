# -------------------------------------------------------------------
#
# Module:         tf-platforms/azure-k8s-ansible
# Submodule:      avset-mgr.tf
# Environments:   all
# Purpose:        Module to define the Azure availability set for the
#                 kubernetes masters.
#
# -------------------------------------------------------------------

resource "azurerm_availability_set" "k8s-avset-mgr" {
  location = var.location
  managed  = true
  name = upper(
    format(
      "%s-AVSET-MGR-%s-%s%s",
      var.vnet-name,
      var.target,
      var.environ,
      local.l-random,
    ),
  )
  platform_fault_domain_count  = "3"
  platform_update_domain_count = "5"
  resource_group_name          = azurerm_resource_group.k8s-rg.name

  tags = var.tags
}

