
output "client_secret" {
  value     = module.service-principal.client_secret
  sensitive = true
}

output "client_id" {
  value     = module.service-principal.client_id
  sensitive = true
}

output "service_principal_application_id" {
  value     = module.service-principal.service_principal_application_id
  sensitive = true
}

output "service_principal_object_id" {
  value     = module.service-principal.service_principal_object_id
  sensitive = true
}

