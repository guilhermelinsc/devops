variable "project_id" {
  type = string
}

variable "source_image_family" {
  type    = string
  default = "ubuntu-2404-lts-amd64"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
} 

variable "image_name" {
  type = string
  default = ""
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}
