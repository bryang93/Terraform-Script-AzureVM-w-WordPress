variable subscription_id {}
variable tenant_id {}
variable client_id {}
variable client_secret {}

provider "azurerm" {
  version = "=1.34.0"

  subscription_id = "bb1fc0b9-b4b7-4dba-a8db-d8b6e3e439d7"
  client_id       = "68287d6f-5ca9-40ef-916f-2d1ad0156af6"
  client_secret   = "B2C2?UcvIRN6FnCXBH4?SAZSB:NZ[vqy"
  tenant_id       = "f64708dc-af27-47aa-b4c8-4465774fa9a4"
}
