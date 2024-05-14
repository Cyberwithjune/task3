terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.26.0"
    }
  }
}

provider "google" {
  # Configuration options
project = "red-studio-419223"
region = "asia-northeast2"
zone = "asia-northeast2-a"
credentials = "red-studio-419223-9822c4dc56cf.json"
}
