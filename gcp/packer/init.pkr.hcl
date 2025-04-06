packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }

    ansible = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}