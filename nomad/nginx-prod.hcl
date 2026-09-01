job "nginx" {
  namespace   = "prod"
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 30080
      }
    }

    task "nginx" {
      driver = "podman"

      config {
        image = "nginx:alpine"

        ports = ["http"]

        volumes = [
          "${NOMAD_META_NGINX_CONFIG}:/etc/nginx/nginx.conf"
        ]
      }

      env {
        NGINX_ENTRYPOINT_QUIET_LOGS = "1"
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
