data "azurerm_subscription" "current" {
}

module "service-principal" {
  source  = "kumarvna/service-principal/azuread"
  version = "2.1.0"

  service_principal_name     = "app-contributor"
  password_rotation_in_years = 2

  # Adding roles and scope to service principal
  assignments = [
    {
      scope                = data.azurerm_subscription.current.id
      role_definition_name = "Contributor"
    },
  ]
}