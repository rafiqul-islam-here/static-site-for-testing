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
        args       = ["-c", "/local/nginx.conf"]
      }

      template {
        data = <<EOF
events {}

http {
    upstream frontend {
        {{ range service "frontend" }}
        server {{ .Address }}:{{ .Port }};
        {{ end }}
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://frontend;

            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

        destination = "local/nginx.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
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