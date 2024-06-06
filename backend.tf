terraform {
  backend "azurerm" {
    resource_group_name  = "sandbox-storage"
    storage_account_name = "az_storage_box"
    container_name       = "terraform"
    key                  = "terraform.tfstate"

  }
}
