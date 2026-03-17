#!/usr/bin/env bash
# ─── scripts/setup-kubespray.sh ───────────────────────────────────────────────
# Instala o Kubespray oficial como Submodule e aplica as correções (patches) 
# necessárias para isolamento do inventário e configurações locais do repositório.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

KUBESPRAY_DIR="kubespray"
PATCH_FILE="${KUBESPRAY_DIR}/roles/download/tasks/download_file.yml"

echo "🔄 1. Inicializando e Atualizando o repositório oficial do Kubespray (Submodule)..."
git submodule update --init --recursive

echo "📦 2. Instalando as dependências Python do Kubespray..."
if command -v pip3 &> /dev/null; then
    pip3 install -r "${KUBESPRAY_DIR}/requirements.txt" || echo "⚠️  Falha ao instalar dependências. Tente usar um Virtual Environment (venv)."
elif command -v pip &> /dev/null; then
    pip install -r "${KUBESPRAY_DIR}/requirements.txt" || echo "⚠️  Falha ao instalar dependências. Tente usar um Virtual Environment (venv)."
else
    echo "⚠️  Python pip não encontrado. Instale-o manualmente."
fi

echo "🔧 3. Aplicando correções (Patching) para compatibilidade de variáveis isoladas..."
if [ -f "${PATCH_FILE}" ]; then
    if grep -q "download_dest_resolved" "${PATCH_FILE}"; then
        echo "✅ Patch The Download Cache issue já estava aplicado."
    else
        sed -i 's/file_path_cached: "{{ download_cache_dir }}\/{{ download.dest | basename }}"/file_path_cached: "{{ download_cache_dir }}\/{{ download.dest }}"/' "${PATCH_FILE}"
        echo "✅ Patch The Download Cache aplicado com sucesso!"
    fi
else
    echo "❌ Arquivo de patch não encontrado: ${PATCH_FILE}"
    exit 1
fi

echo ""
echo "🚀 Kubespray configurado e pronto para uso oficial!"
echo "Você pode rodar playbooks apontando para a NOSSA pasta de inventário segura:"
echo "➡️  cd kubespray && ansible-playbook -i ../ansible-inventory/hosts.ini cluster.yml -b -v --private-key ~/.ssh/id_rsa"
