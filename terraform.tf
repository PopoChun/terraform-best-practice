terraform {
  cloud {
    organization = "bviwit"

    workspaces {
      name = "devops"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }
}
