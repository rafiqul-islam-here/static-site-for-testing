variable "IMAGE" {
  type = string
}

job "nginx" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        static = 30080
        to     = 80
      }
    }

    task "nginx" {
      driver = "podman"

      shutdown_delay = "10s"

      config {
        image      = var.IMAGE
        force_pull = true
        ports      = ["http"]
      }

      resources {
        cpu    = 200
        memory = 128
      }

      service {
        name     = "nginx-prod"
        provider = "nomad"
        port     = "http"

        check {
          name     = "nginx-prod-http"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}