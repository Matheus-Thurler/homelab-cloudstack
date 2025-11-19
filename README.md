# Terraform for Kubernetes on a CloudStack Homelab

This project uses Terraform to automatically provision a complete Kubernetes environment on an Apache CloudStack infrastructure. It is designed to be modular and configurable, making it ideal for a homelab setup.

## Features

-   **VPC Network:** Creates a Virtual Private Cloud (VPC) to isolate resources.
-   **Guest Network:** Provisions an internal network within the VPC for the Kubernetes nodes.
-   **Kubernetes Cluster:** Deploys a Kubernetes cluster, registering the required version and configuring the control-plane and worker nodes.
-   **Modularity:** Organized into reusable Terraform modules (`network`, `kubernetes-cluster`, `kubernetes-version`).

## Prerequisites

-   [Terraform](https://www.terraform.io/downloads.html) (v1.0 or higher) installed.
-   Access to an Apache CloudStack environment with API keys.
-   Service offerings, templates, and zones must be available in your CloudStack.

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Matheus-Thurler/homelab-cloudstack.git
cd homelab-cloudstack
```

### 2. Configure Your Variables

This project uses a `terraform.tfvars` file to manage all your settings. To get started, copy the example file:

```bash
cp homelab.tfvars-example terraform.tfvars
```

Next, edit the `terraform.tfvars` file with your specific details.

⚠️ **IMPORTANT:** This file will contain your CloudStack credentials. It is already included in `.gitignore` to prevent it from being accidentally committed to Git. **Never remove the `terraform.tfvars` line from `.gitignore`!**

#### Example `terraform.tfvars`

```hcl
# CloudStack API Credentials
# --------------------------
api_url    = "http://YOUR-CLOUDSTACK-ENDPOINT:8080/client/api"
api_key    = "YOUR_API_KEY"
secret_key = "YOUR_SECRET_KEY"

# General Settings
# ----------------
zone = "Your-Zone-Name"

# VPC and Network Settings
# ------------------------
vpc_name              = "homelab-vpc"
vpc_cidr              = "10.0.0.0/16"
vpc_offering          = "Default VPC offering" # Name of the VPC offering
network_name          = "homelab-k8s-network"
network_cidr          = "10.0.1.0/24"
network_offering_name = "DefaultIsolatedNetworkOfferingWithSourceNat" # Name of the network offering

# Kubernetes Cluster Settings
# ---------------------------
k8s_cluster_name       = "homelab-k8s-cluster"
k8s_service_offering   = "Large" # Offering for the nodes (e.g., Small, Medium, Large)
k8s_control_nodes_size = 1
k8s_worker_nodes_size  = 2

# Kubernetes Version Settings
# (Adjust according to the version you want to register in CloudStack)
# ---------------------------
k8s_semantic_version = "1.28.2"
k8s_version_name     = "k8s-1.28.2"
k8s_version_url      = "http://path/to/your/template.qcow2"
k8s_min_cpu          = 2
k8s_min_memory       = 2048
```

### 3. Initialize Terraform

This command will download the CloudStack provider and prepare your environment.

```bash
terraform init
```

### 4. Plan and Apply

First, review the execution plan to see what resources will be created.

```bash
terraform plan
```

If everything looks correct, apply the configuration to create the infrastructure.

```bash
terraform apply
```

## Project Modules

This repository is organized into the following modules:

-   `modules/network`: Responsible for creating the VPC, Guest Network, and ACL rules.
-   `modules/kubernetes-version`: Responsible for registering a new Kubernetes version in CloudStack if it doesn't already exist.
-   `modules/kubernetes-cluster`: Responsible for deploying the Kubernetes cluster using the defined network and version.

## Outputs

After the apply is complete, Terraform will display important outputs, such as the IDs of the created resources. If you configure [outputs](https://developer.hashicorp.com/terraform/language/values/outputs), you can see information like:

-   `kubernetes_cluster_id`: The ID of the Kubernetes cluster.
-   `network_id`: The ID of the created network.
