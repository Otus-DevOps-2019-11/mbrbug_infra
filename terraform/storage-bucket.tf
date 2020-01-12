provider "google" {
#  version = "~> 2.5"
##  #version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source   = "SweetOps/storage-bucket/google"
  version  = "0.3.0"
  name     = "mbrbug-bucket-reddit-app"
  location = "europe-west1"
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
