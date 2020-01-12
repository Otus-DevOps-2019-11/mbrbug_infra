terraform {
  backend "gcs" {
    bucket = "mbrbug-bucket-reddit-app"
    prefix = "prod"
  }
}
