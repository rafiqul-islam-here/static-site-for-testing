variable "IMAGE" {
  type = string
}

job "nginx" {
  namespace   = "dev"
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 30081
      }
    }

    task "nginx" {
      driver = "podman"

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
        name     = "nginx-dev"
        provider = "nomad"
        port     = "http"

        check {
          name     = "nginx-dev-http"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}