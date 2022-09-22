variable "params" {
  default = [
    {
      name   = "test"
      paramValue = "* * * * *"
    },
    {
      name   = "test1"
      paramValue = "* * * * *"
    },
    {
      name   = "test2"
      paramValue = "* * * * *"
    },
  ]
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable query_dict {
    default = [
        {
            name = "query1"
            workgroup = "bar"
            query = "SELECT * FROM foo"   
        },
        {
            name = "query2"
            workgroup = "bar"
            query = "SELECT * FROM baz"   
        }
    ]
}
# resource "kubernetes_namespace" "example" {

#   for_each = {for v in var.params: v.name => v.paramValue}
  
#   type  = "String"

#   name = each.key
#   value = each.value
  
#   overwrite = true
# # }

resource "kubernetes_namespace" "example" {
  for_each = {for v in var.params: v.name => v.paramValue}
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = each.key
  }
}

# resource "aws_athena_named_query" "olap" {

#   for_each = {for idx, query in var.query_dict: idx => query}
  
#   name = each.value.name
#   query = each.value.query
#   database = "test"
#   workgroup = each.value.workgroup
# } 

resource "kubernetes_cron_job" "demo" {
  for_each = {for v in var.params: v.name => v.paramValue}
#   for_each = {for idx, query in var.query_dict: idx => query}


  metadata {
    name = each.key
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = each.value
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "hello"
              image   = "busybox"
              command = ["/bin/sh", "-c", "date; echo Hello from the Kubernetes cluster"]
            }
          }
        }
      }
    }
  }
}

