variable "project_id" {
  description = "The unique identifier of the Google Cloud project where resources will be deployed. This is required to manage and associate all resources within the specified project."
}

variable "region" {
  description = "The Google Cloud region where resources will be deployed. This determines the geographical location of the infrastructure and impacts latency, availability, and cost."
  default     = "us-east1"
}

# variable "credentials_file" {
#   description = "File path of the auth keys to connect to GCP account."
# }

variable "network_name" {
  description = "The name of the VPC (Virtual Private Cloud) network where resources will be deployed. This defines the network boundary for communication between cloud resources."
  default     = "webapp-network"
}

variable "subnet_name" {
  description = "The name of the subnet within the specified VPC network where instances will be deployed. This defines the IP range and regional placement of the resources."
  default     = "webapp-subnet"
}
variable "ip_cidr_range" {
  description = "The range of IPs for the private subnet defined by the variable 'subnet_name'."
  default     = "10.10.0.0/24"
}

variable "instance_count" {
  description = "The number of virtual machine instances to be created. This allows for scaling the deployment based on workload requirements."
  default     = 2
}

variable "machine_type" {
  description = "The type of Compute Engine instance to deploy, specifying CPU, memory, and other performance characteristics (e.g., e2-medium, n1-standard-4)."
  default     = "e2-micro"
}

variable "image_family" {
  description = "The OS image family from which the VM instances will be created. This ensures consistency in deployments by always using the latest non-deprecated image from the specified family (e.g., debian-11, ubuntu-minimal-2004-lts)."
  default     = "ubuntu-2404-lts-amd64"
}
