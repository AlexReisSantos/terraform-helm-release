/**
* 
* [![Build Status](https://kantarware.visualstudio.com/KM-Engineering-AMS/_apis/build/status/terraform-helm-release?branchName=master)](https://kantarware.visualstudio.com/KM-Engineering-AMS/_build/latest?definitionId=3094&branchName=master)
*
* # terraform-helm-release
* 
* Terraform module deployment helm chart k8s
* 
* ## Description
* 
* This module dynamically manages helm charts deployments in a k8s cluster.
* Just specify in a list the deployments in a single module call. 
* ## Example usage
*
* - Deploy an nfs-provisioner, providing a declarative file and individual entries.
* - Deploy mysql.
* - Deploy prometheus-operator.
* 
* ```hcl
# module "helm-release" {
#   source = "../"
#   config_context = "minikube"
# 
#   release = {
#     nfs-operator = {
#       repository_name     = "stable"
#       repository_url      = "https://kubernetes-charts.storage.googleapis.com"
#       repository_username = null
#       repository_password = null
#       version             = "1.0.0"
#       chart               = "nfs-server-provisioner"
#       force_update        = true
#       wait                = false
#       recreate_pods       = false
#       timeout             = "3600s"
#       max_history         = 200
#       values              = null
#       set_strings = null
#     }
#     voyager-operator = {
#       repository_name     = "appscode"
#       repository_url      = "https://charts.appscode.com/stable"
#       repository_username = null
#       repository_password = null
#       version             = "v12.0.0-rc.1"
#       chart               = "voyager"
#       force_update        = true
#       wait                = false
#       recreate_pods       = false
#       timeout             = "3600s"
#       max_history         = 200
#       values              = null
#       set_strings = [
#         {
#           name  = "cloudProvider"
#           value = "minikube"
#         }
#       ]
#     }
#     prometheus-operator = {
#       repository_name     = "stable"
#       repository_url      = "https://kubernetes-charts.storage.googleapis.com"
#       repository_username = null
#       repository_password = null
#       version             = "8.12.12"
#       chart               = "prometheus-operator"
#       force_update        = true
#       wait                = false
#       recreate_pods       = false
#       timeout             = "3600s"
#       max_history         = 200
#       values = null
#       set_strings = null
#     }
#     grafana-dashboards = {
#       repository_name     = "amsrtm"
#       repository_url      = "https://amsrtm.azurecr.io/helm/v1/repo"
#       repository_username = "amsrtm"
#       repository_password = "3kJyLrFKisV3YkygEK42Wv+q8DZLIQDm"
#       version             = "1.1.0-release.207227"
#       chart               = "grafana-dashboards"
#       force_update        = true
#       wait                = false
#       recreate_pods       = false
#       timeout             = "3600s"
#       max_history         = 200
#       values = null
#       set_strings = null
#     }
#     rtm-dev = {
#       repository_name     = "amsrtm"
#       repository_url      = "https://amsrtm.azurecr.io/helm/v1/repo"
#       repository_username = "amsrtm"
#       repository_password = "3kJyLrFKisV3YkygEK42Wv+q8DZLIQDm"
#       version             = "1.4.0-beta.207207"
#       chart               = "rtm"
#       force_update        = true
#       wait                = false
#       recreate_pods       = false
#       timeout             = "3600s"
#       max_history         = 200
#       values = null
#       set_strings = null
#     }
#   }
# }
* ```
*/

provider "kubernetes" {
  config_context_cluster   = var.config_context
  config_path = var.config_path
}

provider "helm" {
  version = "v1.2.1"
  kubernetes {
    config_context = var.config_context
    config_path = var.config_path
  }
}

resource "helm_release" "this" {

  for_each = var.release

  name = substr(each.key, 0, 30)
  chart = each.value.chart
  repository = each.value.repository
  repository_username = each.value.repository_name
  repository_password = each.value.repository_password
  version = each.value.version
  namespace = substr(each.key, 0, 30)
  verify = each.value.verify
  timeout = each.value.timeout
  reuse_values = each.value.reuse_values
  reset_values = each.value.reset_values
  force_update = each.value.force_update
  recreate_pods = each.value.recreate_pods
  max_history = each.value.max_history
  wait = each.value.wait
  values = each.value.values

  dynamic "set" {
    iterator = item
    for_each = each.value.set == null ? [] : each.value.set

    content {
      name  = item.value.name
      value = item.value.value
    }
  }

  create_namespace = each.value.create_namespace
}
