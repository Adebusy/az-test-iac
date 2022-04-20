resource "azurerm_network_security_group" "az_security_group" {
  name                = var.network_SG
  location            = azurerm_resource_group.test_RG.location
  resource_group_name = azurerm_resource_group.test_RG.name

  #set rule for inbound traffic
  #   security_rule {
  #     name                       = "SSH"
  #     priority                   = 1001
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_port_range          = "*"
  #     destination_port_range     = "22"
  #     source_address_prefix      = "*"
  #     destination_address_prefix = "*"
  #   }

  custom_rules = [
    {
      name                   = "myhttp"
      priority               = "200"
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "tcp"
      destination_port_range = "8080"
      description            = "description-myhttp"
    },
    {
      name                       = "SSH"
      priority                   = "201"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    environment = "az_test"
  }
}
