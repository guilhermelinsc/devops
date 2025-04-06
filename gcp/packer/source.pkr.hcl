locals {
  image_name = var.image_name != "" ? var.image_name : replace("webapp-${formatdate("YYYYMMDDhhmmss", timestamp())}", ".", "-")
}

source "googlecompute" "webapp" {
  project_id          = var.project_id
  zone                = var.zone
  source_image_family = var.source_image_family
  machine_type        = var.machine_type
  ssh_username        = "packer"
  image_name        = local.image_name
  image_family      = "custom-webapp-family"
  image_description = "Custom image for scalable web app"

  metadata = {
    ssh-keys = "packer:${file("~/.ssh/id_ecdsa.pub")}"
  }
}