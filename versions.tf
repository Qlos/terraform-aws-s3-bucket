terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }

  required_version = ">= 1.0"
}
