#!/usr/bin/env bash
set -e

# === Configuração ===
WORKSPACE=$(terraform workspace show)
CONTEXT_NAME="homelab-${WORKSPACE}"
KUBECONFIG_PATH="${HOME}/.kube/${CONTEXT_NAME}-config"

echo "⚠️ AVISO: 'yq' (jq para yaml) ou 'jq' facilitam o parsing, tentaremos via awk..."
echo "🔍 Detectando estado atual do Terraform..."

raw_ip=$(terraform output -json public_ip)
raw_ports=$(terraform output -json control_ssh_ports)
if [ -z "$raw_ip" ] || [ "$raw_ip" == "null" ]; then
    echo "❌ Erro: IPs não encontrados no terraform output."
    exit 1
fi

CLUSTER_IP=$(python3 -c "import sys, json; print(json.loads(sys.argv[1]))" "${raw_ip}")
CONTROL_SSH_PORT=$(python3 -c "import sys, json; print(list(json.loads(sys.argv[1]).values())[0])" "${raw_ports}")

SSH_KEY="${HOME}/.ssh/id_rsa"

echo "📥 Buscando kubeconfig do workspace '${WORKSPACE}' via [${CLUSTER_IP}:${CONTROL_SSH_PORT}]..."
ssh -q -i "${SSH_KEY}" -p "${CONTROL_SSH_PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "ubuntu@${CLUSTER_IP}" "sudo cp /etc/kubernetes/admin.conf /tmp/admin.conf && sudo chown ubuntu:ubuntu /tmp/admin.conf"
scp -q -i "${SSH_KEY}" -P "${CONTROL_SSH_PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "ubuntu@${CLUSTER_IP}:/tmp/admin.conf" "${KUBECONFIG_PATH}"
ssh -q -i "${SSH_KEY}" -p "${CONTROL_SSH_PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "ubuntu@${CLUSTER_IP}" "rm -f /tmp/admin.conf"

echo "🔧 Ajustando a arvore Base..."
export KUBECONFIG="${KUBECONFIG_PATH}"
kubectl config set-cluster cluster.local --server="https://${CLUSTER_IP}:6443"

echo "🔗 Transformando chaves unicas para '${CONTEXT_NAME}' e mesclando com ~/.kube/config principal..."
sed -i "s/cluster.local/cluster-${CONTEXT_NAME}/g" "${KUBECONFIG_PATH}"
sed -i "s/kubernetes-admin/user-${CONTEXT_NAME}/g" "${KUBECONFIG_PATH}"

kubectl config rename-context "user-${CONTEXT_NAME}@cluster-${CONTEXT_NAME}" "${CONTEXT_NAME}" 2>/dev/null || true

if [ -f "${HOME}/.kube/config" ]; then
    export KUBECONFIG="${HOME}/.kube/config:${KUBECONFIG_PATH}" 
    kubectl config view --flatten > "${HOME}/.kube/config.tmp"
    mv "${HOME}/.kube/config.tmp" "${HOME}/.kube/config"
    chmod 600 "${HOME}/.kube/config"
    echo "✅ Contexto '${CONTEXT_NAME}' injetado com sucesso no ~/.kube/config!"
else
    cp "${KUBECONFIG_PATH}" "${HOME}/.kube/config"
    chmod 600 "${HOME}/.kube/config"
    echo "✅ ~/.kube/config criado do zero com o contexto '${CONTEXT_NAME}'."
fi

rm -f "${KUBECONFIG_PATH}"
unset KUBECONFIG

echo ""
echo "🎲 Para usar o cluster no kubectl digite:"
echo "    kubectl config use-context ${CONTEXT_NAME}"
echo "    kubectl get nodes -o wide"
