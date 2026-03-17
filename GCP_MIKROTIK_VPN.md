# Guia: VPN Site-to-Site — CloudStack ↔ MikroTik ↔ GCP

Este documento descreve a arquitetura e os passos para conectar a rede privada do CloudStack (VPC) à nuvem do Google Cloud Platform (GCP) passando pelo roteador MikroTik local, criando uma rede híbrida unificada.

---

## 🗺️ Arquitetura Alvo

```
VPC do CloudStack (10.50.0.0/16)
  └── k8s-tier (10.50.1.0/24)
        │
        │  IKEv2/IPSec
        ▼
MikroTik (Gateway Local)
  ├── LAN: 10.0.30.0/24 (Management)
  ├── VLAN Pública: 10.0.50.0/24
  └── Túneis VPN:
        │
        ▼ IKEv2/IPSec
VPC do GCP (ex: 10.60.0.0/16)
  └── Subnet GCP (10.60.1.0/24)
```

**Resultado:** Pods no CloudStack acessam serviços GCP (Cloud SQL, GKE, etc.) via IP privado `10.60.x.x`, sem passar pela Internet pública.

---

## Parte 1: CloudStack ↔ MikroTik

### 1.1 Recursos Terraform no CloudStack

```hcl
# VPN Gateway (lado CloudStack)
resource "cloudstack_vpn_gateway" "homelab" {
  vpc_id = module.vpc_network.vpc_id
}

# Customer Gateway (representa o MikroTik)
resource "cloudstack_vpn_customer_gateway" "mikrotik" {
  name       = "mikrotik-homelab"
  gateway    = "<IP_PUBLICO_MIKROTIK>"
  cidr_list  = "10.0.30.0/24"
  esp_policy = "aes256-sha256"
  ike_policy = "aes256-sha256"
  ipsec_psk  = "<CHAVE_PRE_COMPARTILHADA>"
}

# Conexão VPN
resource "cloudstack_vpn_connection" "to_mikrotik" {
  customer_gateway_id = cloudstack_vpn_customer_gateway.mikrotik.id
  vpn_gateway_id      = cloudstack_vpn_gateway.homelab.id
}
```

### 1.2 Configuração no MikroTik (RouterOS)

```routeros
# Proposta IPSec
/ip ipsec proposal
add name=cloudstack auth-algorithms=sha256 enc-algorithms=aes-256-cbc pfs-group=modp1024

# Peer CloudStack
/ip ipsec peer
add name=cloudstack address=<IP_VPN_CLOUDSTACK>/32 exchange-mode=ike2

# Identidade (PSK)
/ip ipsec identity
add peer=cloudstack secret="<CHAVE_PRE_COMPARTILHADA>"

# Política de roteamento para a VPC
/ip ipsec policy
add src-address=10.0.30.0/24 dst-address=10.50.0.0/16 \
    peer=cloudstack tunnel=yes
```

---

## Parte 2: MikroTik ↔ GCP

### 2.1 Recursos Terraform no GCP

```hcl
# VPN Gateway HA no GCP
resource "google_compute_ha_vpn_gateway" "homelab_gw" {
  name    = "homelab-vpn-gw"
  network = google_compute_network.homelab.id
  region  = "us-central1"
}

# Gateway externo (representa o MikroTik)
resource "google_compute_external_vpn_gateway" "mikrotik" {
  name = "mikrotik-gw"
  interface {
    id         = 0
    ip_address = "<IP_PUBLICO_MIKROTIK>"
  }
}

# Túnel VPN
resource "google_compute_vpn_tunnel" "to_mikrotik" {
  name                  = "to-mikrotik"
  ha_vpn_gateway        = google_compute_ha_vpn_gateway.homelab_gw.id
  peer_external_gateway = google_compute_external_vpn_gateway.mikrotik.id
  shared_secret         = "<CHAVE_PRE_COMPARTILHADA>"
  router                = google_compute_router.vpn_router.name
}

# Cloud Router para roteamento
resource "google_compute_router" "vpn_router" {
  name    = "vpn-router"
  network = google_compute_network.homelab.id
  region  = "us-central1"
  bgp {
    asn = 65001
  }
}
```

### 2.2 Configuração no MikroTik (segunda VPN)

```routeros
# Peer GCP
/ip ipsec peer
add name=gcp address=<IP_VPN_GCP>/32 exchange-mode=ike2

# Política de roteamento para a VPC do GCP
/ip ipsec policy
add src-address=0.0.0.0/0 dst-address=10.60.0.0/16 peer=gcp tunnel=yes

# Rota estática
/ip route
add dst-address=10.60.0.0/16 gateway=<IP_TUNNEL_GCP>
```

---

## Parte 3: Roteamento Completo (CloudStack → GCP)

Após os dois túneis ativos, o MikroTik funciona como **hub de roteamento**:

```
Pod no CloudStack (10.50.1.x)
  → Túnel VPN CloudStack → MikroTik
  → Túnel VPN GCP → Cloud SQL / GKE (10.60.x.x)
```

### Rota estática na VPC CloudStack
```bash
cmk create staticroute vpcid=<VPC_ID> cidr=10.60.0.0/16 nexthop=<IP_VPN_GW>
```

### Verificação de conectividade
```bash
# De um pod no cluster CloudStack:
kubectl exec -it <pod> -- ping 10.60.1.1
kubectl exec -it <pod> -- traceroute 10.60.1.1
```

---

## 🔐 Segurança

| Item | Recomendação |
|------|-------------|
| PSK (Chave Pré-Compartilhada) | 32+ caracteres aleatórios |
| Criptografia | AES-256 + SHA-256 (mínimo) |
| ACL CloudStack | Restringir apenas para os CIDRs necessários |
| Firewall GCP | Ingress apenas para `10.50.0.0/16` e `10.0.30.0/24` |
| Monitoramento | Habilitar logs nos túneis VPN do GCP |

---

## 📋 Checklist de Implementação

- [ ] VPC CloudStack criada (`main_vpc.tf` — já feito ✅)
- [ ] Obter IP público do MikroTik
- [ ] Criar `cloudstack_vpn_gateway` e `cloudstack_vpn_customer_gateway`
- [ ] Configurar IPSec no MikroTik para o CloudStack
- [ ] Criar VPN Gateway no GCP e túnel para o MikroTik
- [ ] Configurar segundo IPSec no MikroTik para o GCP
- [ ] Adicionar rotas estáticas na VPC CloudStack
- [ ] Testar conectividade ponta-a-ponta (pod → GCP)
- [ ] Configurar alertas para quedas de túnel
