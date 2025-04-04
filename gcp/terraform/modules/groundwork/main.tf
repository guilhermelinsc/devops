# Create Project's VPC and subnet.

# resource "google_compute_network" "vpc" {
#   name                    = var.network_name
#   auto_create_subnetworks = false
# }

module "vpc" {
  source          = "terraform-google-modules/network/google"
  version         = "~> 10.0"
  project_id      = var.project_id
  network_name    = var.network_name
  shared_vpc_host = false

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.ip_cidr_range
      subnet_region = var.region
    }
  ]

  ingress_rules = [{
    name          = "allow-ssh-ingress"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
    },
    ### Only allow HTTTP access from the GCP Load Balancer. ###
    {
      name          = "allow-http-ingress"
      direction     = "INGRESS"
      source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
      allow = [{
        protocol = "tcp"
        ports    = ["80"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
  }]
}
# resource "google_compute_subnetwork" "subnet" {
#   name          = var.subnet_name
#   network       = module.vpc.network_id
#   ip_cidr_range = var.ip_cidr_range
#   region        = var.region
# }

# module "firewall_rules" {
#   source     = "terraform-google-modules/network/google//modules/firewall-rules"
#   project_id = var.project_id
#   #network_name = google_compute_network.vpc.name
#   network_name = module.vpc.network_name

#   rules = [{
#     name          = "allow-ssh-ingress"
#     direction     = "INGRESS"
#     source_ranges = ["0.0.0.0/0"]
#     allow = [{
#       protocol = "tcp"
#       ports    = ["22"]
#     }]
#     deny = []
#     log_config = {
#       metadata = "INCLUDE_ALL_METADATA"
#     }
#     },
#     {
#       name          = "allow-http-ingress"
#       direction     = "INGRESS"
#       source_ranges = ["0.0.0.0/0"]
#       allow = [{
#         protocol = "tcp"
#         ports    = ["80"]
#       }]
#       deny = []
#       log_config = {
#         metadata = "INCLUDE_ALL_METADATA"
#       }
#   }]
# }

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
    #network    = google_compute_network.vpc.name
    network    = module.vpc.network_id
    subnetwork = module.vpc.subnets_names[0]
    access_config {} # Required for public IP
  }

  metadata_startup_script = "#! /bin/bash\n     sudo apt update\n     sudo apt install apache2 net-tools -y\n     vm_hostname=\"$(curl -H \"Metadata-Flavor:Google\" \\\n   http://169.254.169.254/computeMetadata/v1/instance/name)\"\n   sudo echo \"Page served from: $vm_hostname\" | \\\n   tee /var/www/html/index.html\n   sudo systemctl restart apache2"
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


#  Create the Project's Internet facing components and HealthCheck.

# resource "google_compute_health_check" "webapp_hc" {
#   name               = "webapp-health-check"
#   timeout_sec        = 5
#   check_interval_sec = 10
#   http_health_check {
#     request_path = "/"
#     port         = "80"
#   }
# }

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = ">= 12.0"

  project = var.project_id
  name    = "webapp-health-check"

  backends = {
    default = {
      port               = 80
      protocol           = "HTTP"
      timeout_sec        = 10
      check_interval_sec = 10
      enable_cdn         = false


      health_check = {
        request_path = "/"
        port         = 80
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }
      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group           = google_compute_instance_group_manager.webapp_group.instance_group
          balancing_mode  = "UTILIZATION"
          capacity_scaler = 1.0
        },
      ]
    }


  }
}

# resource "google_compute_backend_service" "webapp_backend" {
#   name          = "webapp-backend"
#   health_checks = [google_compute_health_check.webapp_hc.id]
#   backend {
#     group           = google_compute_instance_group_manager.webapp_group.instance_group
#     balancing_mode  = "UTILIZATION"
#     capacity_scaler = 1.0
#   }
# }

# resource "google_compute_url_map" "webapp_map" {
#   name = "webapp-map"
#   #default_service = google_compute_backend_service.webapp_backend.id
#   default_service = module.gce-lb-http.backend_services.default.id
# }

# resource "google_compute_target_http_proxy" "webapp_proxy" {
#   name    = "webapp-proxy"
#   url_map = module.gce-lb-http.url_map.id
# }

## Remember there is an output of this resource ##

# resource "google_compute_global_forwarding_rule" "webapp_rule" {
#   name       = "webapp-rule"
#   target     = module.gce-lb-http.http_proxy[0]
#   port_range = "80"
# }

# -- End of Internet facing components definition -- #