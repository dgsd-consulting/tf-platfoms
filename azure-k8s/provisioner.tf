# -------------------------------------------------------------------
#
# Module:         k8s-terraform/azure-k8s-ansible
# Submodule:      main.tf
# Environments:   all
# Purpose:        Terraform main.tf module.
#
# Created on:     23 June 2019
# Created by:     David Sanders
# Creator email:  dsanderscanada@nospam-gmail.com
#
# -------------------------------------------------------------------
# Modifed On   | Modified By                 | Release Notes
# -------------------------------------------------------------------
# 23 Jun 2019  | David Sanders               | First release.
# -------------------------------------------------------------------
# 13 Oct 2019  | David Sanders               | Simplify and re-factor
#              |                             | provisioner.
# -------------------------------------------------------------------

resource "null_resource" "provisioner" {
  triggers = {
    vm_k8s_master_1_id = azurerm_virtual_machine.vm-master.id
    jumpboxes = "${join(",", azurerm_virtual_machine.vm-jumpbox.*.id)}"
    workers = "${join(",", azurerm_virtual_machine.vm-workers.*.id)}"
  }

  connection {
    host        = azurerm_public_ip.k8s-pip-jump.*.ip_address[0]
    type        = "ssh"
    user        = var.vm-adminuser
    private_key = file(local.l_pk_file)
  }

  provisioner "file" {
    source      = var.private-key
    destination = "/home/${var.vm-adminuser}/.ssh/azure_pk"
  }

  provisioner "file" {
    source      = "${var.private-key}.pub"
    destination = "/home/${var.vm-adminuser}/.ssh/azure_pk.pub"
  }

  provisioner "file" {
    content     = data.template_file.template-bootstrap.rendered
    destination = "/home/${var.vm-adminuser}/bootstrap.sh"
  }

  provisioner "file" {
    content     = data.template_file.template-hosts-file.rendered
    destination = "/home/${var.vm-adminuser}/hosts"
  }

  provisioner "file" {
    content     = data.template_file.template-ansible-inventory.rendered
    destination = "/home/${var.vm-adminuser}/inventory"
  }

  provisioner "file" {
    content     = data.template_file.template-ssh-config.rendered
    destination = "/home/${var.vm-adminuser}/.ssh/config"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/bootstrap.sh",
      "~/bootstrap.sh",
      "echo 'Done.'",
    ]
  }

# TODO
# Reset DDNS when destroying completely - i.e. not when modifying
# workers

}

