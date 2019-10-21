variable subscription_id {}
variable tenant_id {}
variable client_id {}
variable client_secret {}

provider "azurerm" {
  version = "=1.34.0"

  subscription_id = "XXXX"
  client_id       = "XXXX"
  client_secret   = "XXXX"
  tenant_id       = "XXXX"
}
