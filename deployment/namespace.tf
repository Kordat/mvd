# resource "kubernetes_namespace" "ns_consumer" {
#   metadata {
#     name = "consumer"
#   }
# }

# resource "kubernetes_namespace" "ns_provider" {
#   metadata {
#     name = "provider"
#   }
# }

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"
      "app.kubernetes.io/name"     = "ingress-nginx"
    }
  }
}
