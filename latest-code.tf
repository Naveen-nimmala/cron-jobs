
resource "kubernetes_manifest" "configmap_scripts_configmap" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "run.sh" = <<-EOT
      #!/bin/bash
      apt-get update && apt-get install -y cron vim curl jq
      curl  https://dummyjson.com/products/1 | jq '.brand' >> /tmp/out.txt
      crontab -l ; echo "* * * * * echo "Hello crontab" >> /var/log/cron.log" | crontab -
      echo "$(echo '* * * * * /bin/bash /cron-tab/cron.sh' ; crontab -l 2>&1)" | crontab  -
      cron -f
      sleep infinity
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name"      = "scripts-configmap"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "configmap_cronmap" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "cron.sh" = <<-EOT
      curl  https://dummyjson.com/products/1 | jq '.brand' >/sample.txt

      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name"      = "cron-tab"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "deployment_my_deploy" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "my-deploy"
      }
      "name"      = "my-deploy"
      "namespace" = "default"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "my-deploy"
        }
      }
      "strategy" = {}
      "template" = {
        "metadata" = {
          "creationTimestamp" = null
          "labels" = {
            "app" = "my-deploy"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "/scripts-dir/run.sh",
              ]
              "command" = [
                "/bin/bash",
              ]
              "image" = "ubuntu:latest"
              "name"  = "new-deploy-3"
              "volumeMounts" = [
                {
                  "mountPath" = "/scripts-dir"
                  "name"      = "scripts-vol"
                },
                {
                  "mountPath" = "/cron-tab"
                  "name"      = "cron-tab"
                },
              ]
            },
          ]
          "volumes" = [
            {
              "configMap" = {
                "name" = "scripts-configmap"
              }
              "name" = "scripts-vol"
            },
            {
              "configMap" = {
                "name" = "cron-tab"
              }
              "name" = "cron-tab"
            },
          ]
        }
      }
    }
  }
}
