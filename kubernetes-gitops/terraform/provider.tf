terraform {
  required_providers {
    yandex = {
      source  = "yandex"
      version = "0.97.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"             # Set OAuth or IAM token
  cloud_id                 = "b1gr0rjuncfbqj3p58r0" # Set your cloud ID
  folder_id                = "b1glq3m4u09be6pv76af" # Set your cloud folder ID
  zone                     = "ru-central1-a"        # Availability zone by default, one of ru-central1-a, ru-central1-b, ru-central1-c
}

