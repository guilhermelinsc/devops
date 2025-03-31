output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.webapp_rule.ip_address
}
