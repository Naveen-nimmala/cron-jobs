resource "kubernetes_manifest" "configmap_scripts_configmap" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "run.sh" = <<-EOT
      #!/bin/bash

      apt-get update && apt-get install -y cron vim curl jq
      curl  https://dummyjson.com/products/1 | jq '.brand' >> /tmp/out.txt
      crontab -l ; echo "* * * * * echo "Hello crontab" >> /var/log/cron.log" | crontab -
      cron -f
      echo "Hello from the script residing in helm chart." >> /var/log/cron.log
      echo "New line added here." >> /var/log/cron.log
      echo "Sleeping for eternity!" >> /var/log/cron.log
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
          ]
        }
      }
    }
  }
}
