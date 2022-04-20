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

resource "azurerm_virtual_network" "test_VNet" {
  name                = var.VN_name
  address_space       = var.VN_address_space
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
}

resource "azurerm_subnet" "test_SN" {
  name                 = var.SN_name
  resource_group_name  = azurerm_resource_group.test_RG.name
  virtual_network_name = azurerm_virtual_network.test_VNet.name
  address_prefixes     = var.VN_subnet
}
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name
  allocation_method   = "Dynamic"
}
#create NIC for network
resource "azurerm_network_interface" "test_NIC" {
  name                = var.test_NIC
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test_SN.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.test_RG.name}"
  }
  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storageaccount" {
  name                     = "str${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.test_RG.name
  location                 = azurerm_resource_group.test_RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "${azurerm_resource_group.test_RG.location}"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "az_group_association" {
  network_interface_id      = azurerm_network_interface.test_NIC.id
  network_security_group_id = azurerm_network_security_group.az_security_group.id
}

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "test_VM" {
  name                = var.VM_Name
  resource_group_name = azurerm_resource_group.test_RG.name
  location            = azurerm_resource_group.test_RG.location
  size                = "Standard_DS1_v2"
  network_interface_ids = [
    azurerm_network_interface.test_NIC.id,
  ]

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

  computer_name                   = var.VM_Name
  admin_username                  = var.admin_username
  disable_password_authentication = true



  admin_ssh_key {
    username = var.admin_username
    #public_key = file("~/aws_key.pub")
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
