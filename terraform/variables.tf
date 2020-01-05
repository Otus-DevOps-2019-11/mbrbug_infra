variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable private_key_path {
  description = "path to private key"
}
variable zone {
  description = "zone for instance"
  default     = "europe-west1-b"
}

variable count_inst {
  description = "instances count"
  default     = "1"
}
