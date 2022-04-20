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
