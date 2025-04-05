output "external_ip" {
  value = module.gce-lb-http.external_ip
}

output "backend_services" {
  sensitive = true
  value     = module.gce-lb-http.backend_services
}