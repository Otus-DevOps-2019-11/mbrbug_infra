resource "google_compute_instance" "app-without-puma" {
  count = var.app_provisioner ? 0 : 1

  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params { image = "${var.app_disk_image}" }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    user  = "appuser"
    host  = self.network_interface[0].access_config[0].nat_ip
    agent = false
    #private_key = "${file(var.private_key_path)}"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "../modules/app/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/puma.service /etc/systemd/system/",
      "sudo systemctl enable puma.service",
    ]
  }
}

resource "google_compute_instance" "app-with-puma" {
  count = var.app_provisioner ? 1 : 0

  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params { image = "${var.app_disk_image}" }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    user  = "appuser"
    host  = self.network_interface[0].access_config[0].nat_ip
    agent = false
    #private_key = "${file(var.private_key_path)}"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "../modules/app/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/puma.service /etc/systemd/system/",
      "sudo systemctl enable puma.service",
    ]
  }

  #provisioner "script" {
  #     source      = "../modules/app/deploy.sh"
  #     destination = "/tmp/deploy.sh"
  #   }

  provisioner "remote-exec" {
    script = "../modules/app/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'echo DATABASE_URL = ${var.database_url} >> /etc/environment'",
    ]
  }

}

resource "google_compute_address" "app_ip" { name = "reddit-app-ip" }

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
