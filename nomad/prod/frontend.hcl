variable "IMAGE" {
  type = string
}

job "frontend" {
  namespace   = "prod"
  datacenters = ["dc1"]
  type        = "service"

  group "frontend" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }
    }

    task "frontend" {
      driver = "podman"

      shutdown_delay = "10s"

      config {
        image      = var.IMAGE
        force_pull = true
        ports      = ["http"]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name     = "frontend-prod"
        provider = "nomad"
        port     = "http"

        check {
          name     = "frontend-prod-http"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}