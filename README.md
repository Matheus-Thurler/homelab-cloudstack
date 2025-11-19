# homelab-cloudstack
    git clone https://github.com/your-username/homelab-cloudstack.git
    cd homelab-cloudstack
    ```

2.  **Configure your variables:**

    This project uses a `terraform.tfvars` file to customize your deployment. A template file, `homelab.tfvars.example`, is provided to guide you.

    **Create your `terraform.tfvars` file:**

    ```bash3.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

4.  **Review and Apply:**

    ```bash
    terraform plan
    terraform apply
    
    cp homelab.tfvars.example terraform.tfvars
    ```

    **Edit `terraform.tfvars`:**

    Open `terraform.tfvars` in your preferred text editor and modify the values to match your homelab environment. This file will contain sensitive information, so ensure it's properly secured and **do not commit it to version control**.

    Here's an example of the variables you'll need to configure in `terraform.tfvars`:

    