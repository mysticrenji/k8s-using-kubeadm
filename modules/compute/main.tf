#Create virtual machine
resource "azurerm_linux_virtual_machine" "virtualmachine" {
  name                  = var.vmname
  location              = var.location
  resource_group_name   = var.resourcegroup
  network_interface_ids = var.nic
  size                  = var.vmsize # "Standard_ D2S_v3"
  admin_username        = "azureuser"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.publickey #tls_private_key.ssh.public_key_openssh
  }

  tags = {
    environment = "k8sdev"
  }


}

#Bootstrapping essential packages
resource "azurerm_virtual_machine_extension" "customscripts" {
  name                 = var.vmname
  virtual_machine_id   = azurerm_linux_virtual_machine.virtualmachine.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/mysticrenji/k8s-using-kudeadm/main/script.sh"],
        "commandToExecute": "sh script.sh"
    }
SETTINGS
  tags = {
    environment = "k8sdev"
  }

}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = <<EOT
      cd ansible
      sleep 300;
      >$public_ip;
      echo "[$public_ip]" | tee -a $public_ip;
      echo "$public_ip ansible_user=$user ansible_ssh_private_key_file=$private_key_path" | tee -a $public_ip;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      ansible-playbook -u $user --private-key $private_key_path -i $public_ip $provisoner
    EOT

    environment = {
      public_ip        = azurerm_linux_virtual_machine.virtualmachine.public_ip_address #"${element(azurerm_linux_virtual_machine.virtualmachine.*.public_ip_address, count.index)}"
      provisoner       = azurerm_linux_virtual_machine.virtualmachine.name == "k8sdev-master" ? "master-provisioner.yaml" : "slave-provisioner.yaml"
      private_key_path = var.private_key_path
      user             = "azureuser"
    }
  }
  depends_on = [azurerm_virtual_machine_extension.customscripts]
}