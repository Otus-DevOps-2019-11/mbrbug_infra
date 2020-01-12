variable zone {
  description = "instance zone"
}

variable app_disk_image {
  description = "instance image"
  default     = "reddit-app-base"
}

variable public_key_path {
  description = "instance ssh-key"
}

variable private_key_path {
  description = " private ssh-key"
}

variable machine_type {
  default = "g1-small"
}

variable database_url {
  description = "database url"
}

variable app_provisioner {
  description = "turn on off puma provisioner"
}
