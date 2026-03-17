#!/usr/bin/env bash
# ─── install-csi.sh ───────────────────────────────────────────────────────────
# Instala o CloudStack CSI Driver no cluster Kubernetes.
# Permite ao Kubernetes provisionar novos Discos (Volumes) de Bloco diretamente
# do hypervisor/datastore do CloudStack e atrelá-los às VMs/Pods.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/config}"
export KUBECONFIG

echo "📦 Instalando CloudStack CSI Driver..."

# A mesma API/Secret do CCM funciona para o CSI. Então garantimos que ela exista:
if ! kubectl get secret cloudstack-secret -n kube-system >/dev/null 2>&1; then
    echo "⚠️ Secret cloudstack-secret não encontrado! Você instalou o CCM primeiro?"
    exit 1
fi

# Utiliza a release oficial do Apache CloudStack CSI Driver
# Note: As implementações do CSI são mantidas out-of-tree pela APACHE.
CSI_VERSION="v1.2.1"
MANIFEST_URL="https://raw.githubusercontent.com/apache/cloudstack-csi-driver/main/deployment/csi-cloudstack.yaml"

echo "Aplicando Manifesto CSI (versão target)..."
kubectl apply -f "${MANIFEST_URL}"

echo "CSI implantado. Aguardando Pods subirem..."
kubectl -n kube-system rollout status ds/csi-cloudstack-node --timeout=120s

echo ""
echo "✅ Instalando StorageClass default 'cloudstack-custom'..."
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cloudstack-custom
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi.cloudstack.apache.org
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF

echo ""
echo "🔥 Tudo pronto! Execute: kubectl get sc"
