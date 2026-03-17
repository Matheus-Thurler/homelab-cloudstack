#!/usr/bin/env bash
# ─── install-ccm.sh ───────────────────────────────────────────────────────────
# Instala o CloudStack Cloud Controller Manager no cluster.
# Deve ser rodado DEPOIS que o cluster estiver up (kubectl get nodes = Ready).
#
# O CCM habilita:
#   - Sincronização de estado dos nós com CloudStack
#   - Criação automática de Load Balancer Rules no CloudStack quando um
#     Service do tipo LoadBalancer é criado (ex: nginx ingress)
#
# Uso:
#   export KUBECONFIG=~/.kube/homelab-config
#   ./install-ccm.sh
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/config}"
MANIFESTS_DIR="$(dirname "$0")/../k8s/ccm"
export KUBECONFIG

echo "📦 Instalando CloudStack Cloud Controller Manager..."
echo ""

echo "1/3 Aplicando RBAC (ServiceAccount, ClusterRole, ClusterRoleBinding)..."
kubectl apply -f "${MANIFESTS_DIR}/rbac.yaml"

echo "2/3 Criando Secret com credenciais do CloudStack..."
kubectl apply -f "${MANIFESTS_DIR}/secret.yaml"

echo "3/3 Instalando DaemonSet do CCM..."
kubectl apply -f "${MANIFESTS_DIR}/daemonset.yaml"

echo ""
echo "⏳ Aguardando CCM ficar disponível..."
kubectl -n kube-system rollout status daemonset/cloudstack-cloud-controller-manager --timeout=120s

echo ""
echo "✅ CloudStack CCM instalado com sucesso!"
echo ""
echo "Verificar pods:"
echo "  kubectl -n kube-system get pods -l k8s-app=cloudstack-cloud-controller-manager"
echo ""
echo "Ver logs:"
echo "  kubectl -n kube-system logs -l k8s-app=cloudstack-cloud-controller-manager -f"
