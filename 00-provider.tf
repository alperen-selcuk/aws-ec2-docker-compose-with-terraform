terraform {

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "devopsdude"
}

provider "tls" {
}

provider "random" {
}
