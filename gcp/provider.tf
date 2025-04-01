terraform {
  backend "gcs" {
    bucket = "tf_glcs_backend"
    #prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>6.17"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = file(var.credentials_file)
}