# -------------------------------------------------------------------
#
# Module:         tf-platforms/azure-k8s-ansible
# Submodule:      vm-jumpox.tf
# Environments:   all
# Purpose:        Module to define the Azure virtual machine for the
#                 jumpbox.
#
# -------------------------------------------------------------------

resource "azurerm_virtual_machine" "vm-workers" {
  count = local.l_workers_vm_count

  depends_on = [
    "azurerm_network_interface.k8s-nic-workers"
  ]

  availability_set_id              = azurerm_availability_set.k8s-avset-wrk.id
  delete_os_disk_on_termination    = var.workers.delete_os
  delete_data_disks_on_termination = var.workers.delete_data
  location                         = var.location
  name = upper(
    format(
      "VM-WRK-%01d-%s-%s%s",
      count.index + 1,
      var.target,
      var.environ,
      local.l-random,
    ),
  )

  network_interface_ids = [azurerm_network_interface.k8s-nic-workers.*.id[count.index]]
  resource_group_name   = azurerm_resource_group.k8s-rg.name
  vm_size               = var.worker-vm-size

  boot_diagnostics {
    storage_uri = azurerm_storage_account.k8s-sa-boot-diag.primary_blob_endpoint
    enabled     = true
  }

  storage_image_reference {
    id = format(
      "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/images/%s",
      var.subscription_id,
      var.workers.image-rg,
      var.workers.image-id
    )
  }

  storage_os_disk {
    name = format(
      "OSD-WRK-%01d-%s-%s%s",
      count.index + 1,
      var.target,
      var.environ,
      local.l-random,
    )
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.vm-osdisk-type
  }

  os_profile {
    computer_name = upper(
      format(
        "%s-%01d",
        var.workers.prefix,
        count.index + 1
      ),
    )
    admin_username = var.vm-adminuser
    admin_password = var.vm-adminpass
    custom_data    = ""
  }

  os_profile_linux_config {
    disable_password_authentication = var.vm-disable-password-auth

    ssh_keys {
      path     = "/home/${var.vm-adminuser}/.ssh/authorized_keys"
      key_data = var.private-key-pub
    }
  }

  tags = var.tags
}


# resource "azurerm_virtual_machine" "vm-workers" {
#   #   count = "${length(local.l_vm_worker_ids)}"
#   count = "2"

#   availability_set_id              = azurerm_availability_set.k8s-avset-wrk.id
#   delete_os_disk_on_termination    = "true"
#   delete_data_disks_on_termination = "true"
#   location                         = var.location
#   name = upper(
#     format(
#       "VM-WRK-%01d-%s-%s%s",
#       count.index + 1,
#       var.target,
#       var.environ,
#       local.l-random,
#     ),
#   )
#   # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
#   # force an interpolation expression to be interpreted as a list by wrapping it
#   # in an extra set of list brackets. That form was supported for compatibility in
#   # v0.11, but is no longer supported in Terraform v0.12.
#   #
#   # If the expression in the following list itself returns a list, remove the
#   # brackets to avoid interpretation as a list of lists. If the expression
#   # returns a single list item then leave it as-is and remove this TODO comment.
#   network_interface_ids = [local.l_vm_worker_ids[count.index]]
#   resource_group_name   = azurerm_resource_group.k8s-rg.name
#   vm_size               = var.worker-vm-size

#   boot_diagnostics {
#     storage_uri = azurerm_storage_account.k8s-sa-boot-diag.primary_blob_endpoint
#     enabled     = true
#   }

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name = format(
#       "OSD-WRK-%01d-%s-%s%s",
#       count.index + 1,
#       var.target,
#       var.environ,
#       local.l-random,
#     )
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = var.vm-osdisk-type
#   }

#   os_profile {
#     computer_name = upper(
#       format(
#         "%s-WORKER-%01d-%s-%s%s",
#         var.vm-name,
#         count.index + 1,
#         var.target,
#         var.environ,
#         local.l-random,
#       ),
#     )
#     admin_username = var.vm-adminuser
#     admin_password = var.vm-adminpass
#     custom_data    = ""
#   }

#   os_profile_linux_config {
#     disable_password_authentication = var.vm-disable-password-auth

#     ssh_keys {
#       path     = "/home/${var.vm-adminuser}/.ssh/authorized_keys"
#       key_data = file(format("%s.pub", var.private-key))
#     }
#   }

#   tags = var.tags
# }

