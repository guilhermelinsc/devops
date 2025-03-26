terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>6.17"
    }
  }
}

provider "google" {
  project     = "modular-rex-454820-v2"
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = file(var.credentials_file)
}