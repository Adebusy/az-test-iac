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
