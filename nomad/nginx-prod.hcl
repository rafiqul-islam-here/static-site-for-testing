variable "IMAGE" {
  type = string
}

job "nginx" {
  namespace   = "prod"
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

      template {
        data = <<EOF
events {}

http {
    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://172.26.64.16:80;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

        destination = "local/nginx.conf"
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