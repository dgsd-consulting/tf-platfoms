# -------------------------------------------------------------------
#
# Module:         tf-platforms/azure-k8s-ansible
# Submodule:      locals.tf
# Environments:   all
# Purpose:        Module to define local variables.
#
# -------------------------------------------------------------------

locals {
  l-random     = substr(lower(var.environment_flag), 0, 3) == "dev" ? format("-%s", random_integer.unique-sa-id.result) : ""
  l-random-int = <<-EOF
    substr(lower(var.environment_flag), 0, 3) == "dev"
    ? format("%s", random_integer.unique-sa-id.result) 
    : substr(lower(var.environment_flag), 0, 4) == "blue" or
      substr(lower(var.environment_flag), 0, 4) == "green"
      ? format("%s", random_integer.unique-sa-id.result)
      : ""
  EOF
  l-dev        = ""
  l-dev-lower  = ""
  l_masters_vm_count = 1
  l_workers_vm_count = var.workers.vm-count < 2 ? 2 : var.workers.vm-count
  l_jumpboxes_vm_count = var.jumpboxes.vm-count < 1 ? 1 : var.jumpboxes.vm-count
}
