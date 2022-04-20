terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test_RG" {
  name     = var.RG_Name
  location = var.RG_Location
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "az_group_association" {
  network_interface_id      = azurerm_network_interface.test_NIC.id
  network_security_group_id = azurerm_network_security_group.az_security_group.id
}

resource "azurerm_linux_virtual_machine" "test_VM" {
  name                = var.VM_Name
  resource_group_name = azurerm_resource_group.test_RG.name
  location            = azurerm_resource_group.test_RG.location
  size                = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.test_NIC.id,
  ]
  computer_name                   = var.VM_Name
  admin_username                  = var.admin_username
  disable_password_authentication = true


  os_disk {
    name                 = "${var.VM_Name}-dsk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = self.public_ip_address
      private_key = tls_private_key.example_ssh.private_key_openssh
      agent       = false
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker.io -y",
      "git clone https://github.com/Adebusy/AlaoTest.git",
      "sudo docker build -t myapp ./AlaoTest",
      "sudo docker run -d -p 80:8060 myapp"
    ]
  }
}

output "name" {
  value = azurerm_linux_virtual_machine.test_VM.name
}
