# homelab-cloudstack 🏡☸️

Automação completa para provisionar um cluster Kubernetes altamente disponível no **Apache CloudStack** usando **Terraform + Kubespray**. Suporta dois modelos de rede: **Rede Isolada** (padrão) e **VPC** (para redes híbridas e VPN futura).

---

## ✨ Funcionalidades

- **Dois modelos de rede**: Rede Isolada (simples e rápida) + VPC (preparada para VPN Site-to-Site)
- **Kubespray Sem Bastion**: acesso direto às VMs via Port Forwarding, sem VM intermediária
- **Inventário Dinâmico**: `hosts.ini` gerado automaticamente pelo Terraform após cada `apply`
- **Cloud Controller Manager (CCM)**: serviços `LoadBalancer` criam IPs públicos no CloudStack automaticamente
- **CSI Driver**: provisionamento automático de volumes de bloco (Persistent Volumes) do CloudStack
- **Bypass Layer-2 para o CCM**: a API do CloudStack é acessada via espelho na VLAN pública para contornar bloqueios de roteamento inter-VLAN

---

## 🏗️ Arquitetura

### Modelo 1: Rede Isolada (`main.tf`)

```
Sua máquina local
  ├── Terraform  → provisiona VMs, rede, port forwards e LB no CloudStack
  ├── Kubespray  → instala o k8s nas VMs via SSH (direto, sem bastion)
  └── kubectl    → acessa o cluster via LB (10.0.50.106:6443)

CloudStack — Rede Isolada (homelab-k8s-network | 10.30.1.0/24)
  ├── k8slab-control-0/1  → Port Forward :22001/:22002
  ├── k8slab-worker-0/1/2 → Port Forwards :22003-22005
  └── Load Balancer :6443 → control plane (API do Kubernetes)
```

### Modelo 2: VPC (`main_vpc.tf`)

```
CloudStack — VPC (homelab-vpc | 10.50.0.0/16)
  └── Tier: k8s-tier (10.50.1.0/24)
      ├── ACLs: Allow 22, 22000-23999, 6443
      ├── k8svpc-control-0 → Port Forward :23000
      └── k8svpc-worker-0  → Port Forward :23001
```

> A VPC é o modelo recomendado para futura integração com VPN Site-to-Site (MikroTik ↔ GCP).
> Veja [GCP_MIKROTIK_VPN.md](./GCP_MIKROTIK_VPN.md) para o roadmap de conectividade híbrida.

---

## 📁 Estrutura do Repositório

```
homelab-cloudstack/
├── main.tf                    # Cluster com Rede Isolada
├── main_vpc.tf                # Cluster com VPC (modo de teste)
├── variable.tf                # Variáveis globais
├── outputs.tf                 # Outputs (IPs, portas SSH, etc.)
├── homelab.tfvars             # Configuração local (não commitar!)
├── homelab.tfvars-example     # Template de configuração
│
├── modules/
│   ├── network/               # Rede Isolada + Firewall
│   ├── vpc-network/           # VPC + Tier + ACLs
│   └── kubespray-cluster/     # Instâncias, LB, Port Forwards, Inventário
│
├── scripts/
│   ├── setup-kubespray.sh     # Inicializa o submodule do Kubespray
│   ├── get-kubeconfig.sh      # Extrai o kubeconfig do cluster
│   ├── install-ccm.sh         # Instala o Cloud Controller Manager
│   └── install-csi.sh         # Instala o CSI Driver
│
├── k8s/ccm/                   # Manifests do Cloud Controller Manager
├── ansible-inventory/         # Inventário Ansible gerado pelo Terraform
└── kubespray/                 # Git Submodule oficial do Kubespray
```

---

## 🚀 Primeiros Passos

### Pré-requisitos
- Terraform v1.0+
- Ansible + Python 3 + pip
- Chaves de API do Apache CloudStack
- Chave SSH cadastrada no CloudStack

### 1. Configurar o ambiente

```bash
git clone https://github.com/Matheus-Thurler/homelab-cloudstack.git
cd homelab-cloudstack
./scripts/setup-kubespray.sh
cp homelab.tfvars-example homelab.tfvars
# Edite homelab.tfvars com suas credenciais e configurações
```

### 2. Provisionar a infraestrutura

```bash
terraform init
terraform apply --var-file=homelab.tfvars
# O hosts.ini é gerado automaticamente em ansible-inventory/
```

### 3. Instalar o Kubernetes

```bash
cd kubespray
ANSIBLE_ROLES_PATH=roles ansible-playbook \
  -i ../ansible-inventory/hosts.ini cluster.yml \
  -b -v --private-key ~/.ssh/id_rsa
cd ..
```

### 4. Acessar o cluster

```bash
./scripts/get-kubeconfig.sh
export KUBECONFIG=~/.kube/homelab-config
kubectl get nodes
```

### 5. Instalar CCM e CSI

```bash
./scripts/install-ccm.sh  # Serviços LoadBalancer automáticos
./scripts/install-csi.sh  # Persistent Volumes automáticos
```

### 6. Escalar workers (sem reinstalar)

```bash
# Aumentar worker_count no homelab.tfvars
terraform apply --var-file=homelab.tfvars
cd kubespray
ANSIBLE_ROLES_PATH=roles ansible-playbook \
  -i ../ansible-inventory/hosts.ini scale.yml \
  -b -v --private-key ~/.ssh/id_rsa
```

> ⚠️ **Use `scale.yml`** para adicionar nós. O `cluster.yml` reconfigura tudo e pode causar disrupção.

---

## 🔧 Detalhes Técnicos

### Kubespray Sem Bastion com Port Forwarding
O Kubespray roda direto da máquina local. O `inventory.tf` gera o `hosts.ini` com `ansible_host` apontando para o IP público e `ansible_port` para a porta de port forward de cada nó (`22001`, `22002`, etc). Os campos `ip=` e `access_ip=` recebem os IPs **internos** para comunicação intra-cluster.

### Bypass Layer-2 do CCM
O Cloud Controller Manager aponta para `http://10.0.50.254:8080` (espelho do Management Server na VLAN pública), evitando bloqueios de roteamento inter-VLAN do pfSense sem precisar alterar roteadores.

### Patch no Kubespray (`download_file.yml`)
O Kubespray possui um bug onde `download.dest` com template string não é avaliado antes do filtro `| basename`. O patch resolve o caminho em duas etapas com `set_fact` intermediário.

---

## 🌐 Roadmap: Rede Híbrida (VPN + GCP)

A arquitetura VPC (`main_vpc.tf`) é o passo inicial de um roadmap maior:

1. ✅ **VPC CloudStack** — Implementado. Suporte a ACLs e estrutura de Tiers.
2. 🔜 **VPN Site-to-Site** — Conectar a VPC ao roteador MikroTik local via IKEv2/IPSec.
3. 🔜 **VPN MikroTik ↔ GCP** — Criar um túnel do MikroTik para a VPC do Google Cloud.
4. 🔜 **Roteamento Híbrido** — Pods do CloudStack acessando serviços GCP pela rede privada.

Para detalhes técnicos de implementação: [GCP_MIKROTIK_VPN.md](./GCP_MIKROTIK_VPN.md)

---

## 🧩 Variáveis Principais (`homelab.tfvars`)

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `zone` | Nome da zona CloudStack | `"Homelab-Zone"` |
| `template` | Template da VM | `"Ubuntu 24.04"` |
| `keypair_name` | Keypair SSH no CloudStack | `"minha-chave"` |
| `control_count` | Nós de control plane | `2` |
| `worker_count` | Nós worker | `3` |
| `ssh_base_port` | Primeira porta SSH pública | `22001` |
| `network_cidr` | CIDR da rede interna | `"10.30.1.0/24"` |

---

## 📊 Stack Atual

| Componente | Versão/Valor |
|------------|--------------|
| Kubernetes | v1.35.1 |
| Container Runtime | containerd |
| CNI | Calico |
| CCM | cloudstack-kubernetes-provider |
| Endpoint da API | `https://10.0.50.106:6443` |
