job "web-stack" {
  datacenters = ["dc1"]
  type = "service"

  variable "FRONTEND_IMAGE" {
    type = string
  }

  variable "NGINX_IMAGE" {
    type = string
  }

  group "web" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        static = 30080
        to = 80
      }

      port "frontend" {
        to = 3000
      }
    }

    task "frontend" {
      driver = "podman"

      config {
        image = var.FRONTEND_IMAGE
      }

      resources {
        cpu = 500
        memory = 512
      }
    }

    task "nginx" {
      driver = "podman"

      config {
        image = var.NGINX_IMAGE
      }

      lifecycle {
        hook = "poststart"
        sidecar = true
      }

      resources {
        cpu = 200
        memory = 128
      }
    }
  }
}