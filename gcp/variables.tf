variable "project_id" {}
variable "region" { default = "us-east1" }
variable "credentials_file" {}
variable "network_name" { default = "webapp-network" }
variable "subnet_name" { default = "webapp-subnet" }
variable "instance_count" { default = 2 }
variable "machine_type" { default = "e2-medium" }
variable "image_family" { default = "your-custom-packer-image" }
