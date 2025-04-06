# Create Project's VPC and subnet.

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

# Create the compute instance template to use for the compute instances and Instance group backend.

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 13.0"

  name_prefix          = "webapp-template"
  project_id           = var.project_id
  machine_type         = var.machine_type
  region               = var.region
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project
  disk_size_gb         = 20
  network              = module.vpc.network_id
  subnetwork           = module.vpc.subnets_self_links[0]
  # Required for public IP
  access_config = [{
    network_tier = "STANDARD"
  }]
  startup_script = "#! /bin/bash\n     vm_hostname=\"$(curl -H \"Metadata-Flavor:Google\" \\\n   http://169.254.169.254/computeMetadata/v1/instance/name)\"\n   sudo echo \"Page served from: $vm_hostname\" | \\\n   tee /var/www/html/index.html\n   sudo systemctl restart apache2"
  #startup_script = file("~/devops/gcp/terraform/modules/groundwork/start.sh")
}

module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 13.0"

  project_id        = var.project_id
  region            = var.region
  target_size       = var.instance_count
  hostname          = "webapp"
  instance_template = module.instance_template.self_link

  named_ports = [{
    name = "http"
    port = 80
  }]
}

#  Create the Project's Internet facing components and HealthCheck.

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
          group           = module.mig.instance_group
          balancing_mode  = "UTILIZATION"
          capacity_scaler = 1.0
        },
      ]
    }


  }
}