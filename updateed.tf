
resource "kubernetes_config_map" "example-2" {
  metadata {
    name = "my-yaml"
  }

  data = {
    "my-yaml.yml" = "${file("./test.yml")}"
  }

}

resource "kubernetes_config_map" "example-3" {
  metadata {
    name = "my-update"
  }

  data = {
    "update.sh" = "${file("./update.sh")}"
  }

}

resource "kubernetes_manifest" "configmap_scripts_configmap" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "run.sh" = <<-EOT
      #!/bin/bash
      apt-get update && apt-get install -y cron vim jq curl python3-pip
      pip3 install yq
      service cron start
      /bin/bash /update/update.sh &
      /bin/bash /cron-tab/my_config_file.sh

      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name"      = "scripts-configmap"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_config_map" "example" {
  metadata {
    name = "my-config"
  }

  data = {
    "my_config_file.sh" = "${file("./final.sh")}"
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
      "template" = {
        "metadata" = {
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
                  "mountPath" = "/scripts-dir/"
                  "name"      = "scripts-vol"
                },
                {
                  "mountPath" = "/cron-tab/"
                  "name"      = "cron-tab"
                },
                {
                  "mountPath" = "/data/"
                  "name"      = "my-yaml"
                },
                {
                  "mountPath" = "/update/"
                  "name"      = "my-update"
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
                "name" = "my-config"
              }
              "name" = "cron-tab"
            },
            {
              "configMap" = {
                "name" = "my-yaml"
              }
              "name" = "my-yaml"
            },
            {
              "configMap" = {
                "name" = "my-update"
              }
              "name" = "my-update"
            },
          ]
        }
      }
    }
  }
}
