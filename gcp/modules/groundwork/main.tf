# Create Project's VPC and subnet.

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
}

# -- End of network definition -- #

# Create the compute instance template to use for the compute instances.

resource "google_compute_instance_template" "webapp_template" {
  name         = "webapp-template"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.image_family
    auto_delete  = true
    disk_size_gb = 20
    boot         = true
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    access_config {} # Required for public IP
  }

  metadata_startup_script = "echo 'Hello, World!' > /var/www/html/index.html"
}

resource "google_compute_instance_group_manager" "webapp_group" {
  name               = "webapp-group"
  base_instance_name = "webapp"
  #region             = var.region
  target_size = var.instance_count

  version {
    instance_template = google_compute_instance_template.webapp_template.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

# -- End of Instance Template definition -- #


#  Create the Project's Internet facing components.

resource "google_compute_health_check" "webapp_hc" {
  name               = "webapp-health-check"
  timeout_sec        = 5
  check_interval_sec = 10
  http_health_check {
    port = "80"
  }
}

resource "google_compute_backend_service" "webapp_backend" {
  name          = "webapp-backend"
  health_checks = [google_compute_health_check.webapp_hc.id]
}

resource "google_compute_url_map" "webapp_map" {
  name            = "webapp-map"
  default_service = google_compute_backend_service.webapp_backend.id
}

resource "google_compute_target_http_proxy" "webapp_proxy" {
  name    = "webapp-proxy"
  url_map = google_compute_url_map.webapp_map.id
}

resource "google_compute_global_forwarding_rule" "webapp_rule" {
  name       = "webapp-rule"
  target     = google_compute_target_http_proxy.webapp_proxy.id
  port_range = "80"
}

# -- End of Internet facing components definition -- #