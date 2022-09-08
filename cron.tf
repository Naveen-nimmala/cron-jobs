resource "kubernetes_manifest" "deployment_my_deploy" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "my-deploy"
      }
      "name" = "my-deploy"
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
              "name" = "new-deploy-3"
              "volumeMounts" = [
                {
                  "mountPath" = "/scripts-dir"
                  "name" = "scripts-vol"
                },
                {
                  "mountPath" = "/cron-tab"
                  "name" = "cron-tab"
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
                "name" = "cronmap"
              }
              "name" = "cron-tab"
            },
          ]
        }
      }
    }
  }
}
