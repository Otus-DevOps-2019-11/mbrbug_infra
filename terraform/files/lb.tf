resource "google_compute_target_pool" "reddit-app-target-pool" {
  name = "reddit-app-target-pool"

  instances = google_compute_instance.app[*].self_link

  health_checks = [
    google_compute_http_health_check.reddit-http-hc.name,
  ]
}

resource "google_compute_http_health_check" "reddit-http-hc" {
  name                = "reddit-http-hc"
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5
  port                = 9292

}

resource "google_compute_forwarding_rule" "reddit-fr" {
  name                  = "reddit-fr"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_pool.reddit-app-target-pool.self_link
  port_range            = 9292
}
