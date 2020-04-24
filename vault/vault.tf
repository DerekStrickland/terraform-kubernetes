resource "helm_release" "vault" {
  count     = data.terraform_remote_state.cluster.outputs.enable_consul_and_vault ? 1 : 0
  name      = "${data.terraform_remote_state.consul.outputs.release_name}-vault"
  chart     = "${path.module}/vault-helm"
  namespace = data.terraform_remote_state.consul.outputs.namespace

  set {
    name  = "server.ha.enabled"
    value = "true"
  }

  set {
    name  = "server.ha.config"
    value = <<EOT
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "consul" {
        path = "vault"
        address = "HOST_IP:8500"
      }

      service_registration "consul" {
        address = "HOST_IP:8500"
      }
    EOT
  }
}