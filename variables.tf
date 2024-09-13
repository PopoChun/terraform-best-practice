variable "project" {
  description = "Name of the project"
  type        = string
  default     = "devops-xxxxxxx"
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "asia-east1"
}

variable "zone" {
  description = "GCE zone for all instances"
  type        = string
  default     = "asia-east1-a"
}

variable "vpc" {
  type    = string
  default = "awesome"
}

variable "subnets" {
  type = list(any)
  default = [
    {
      name = "awesome-subnet"
      cidr = "10.140.1.0/24"
    }
  ]
}

variable "ingress_rules" {
  description = "ingress rules"
  type        = list(any)
  default = [
    {
      name = "allow-iap"
      allow = [
        {
          protocol = "tcp"
          ports    = []
        }
      ]
      source_ranges = ["35.235.240.0/20"]
      target_tags   = []
    },
    {
      name = "allow-icmp"
      allow = [
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      target_tags   = []
    },
    {
      name = "allow-internal"
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      source_ranges = ["10.140.1.0/24"]
      target_tags   = []
    },
    {
      name = "allow-http"
      allow = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["http"]
    },
    {
      name = "allow-https"
      allow = [
        {
          protocol = "tcp"
          ports    = ["443"]
        }
      ]
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["https"]
    },
  ]
}

variable "default_sa" {
  type    = string
  default = "921861072155-compute@developer.gserviceaccount.com"
}

variable "instances" {
  description = "creating instances"
  type        = map(any)
  default = {
    vm1 = {
      machine_type   = "e2-small"
      boot_disk_size = 30
      image          = "centos-7"
      tags           = []
      subnet         = "awesome-subnet"
      static_ip      = false
      # service_account = "921861072155-compute@developer.gserviceaccount.com"
    }
  }
}

variable "attached_disks" {
  description = "additional disk for data"
  type        = map(any)
  default = {
    vm1 = {
      type     = "pd-balanced"
      size     = 100
      instance = "vm1"
    },
  }
}
