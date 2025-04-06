# Terraform Code for Web Server with Load Balancer

This project aims to automate the deployment of a WebServer using **Terraform, Packer, and Ansible.**

Currently, this project provisions the infrastructure on **Google Cloud Platform (GCP)** using **Terraform**, to deploy a scalable web server environment behind a **load balancer**. 

Each web server node serves a sample page that displays its own hostname, demonstrating which instance handled the request and the load balancer in action.

## 📁 Project Structure

```
── gcp
│  ├─ packer
│  │  ├─ ansible
│  │  │  └─ playbook.yml
│  │  ├─ build.pkr.hcl
│  │  ├─ init.pkr.hcl
│  │  ├─ source.pkr.hcl
│  │  └─ variables.pkr.hcl
│  └─ terraform
│     ├─ .terraform.lock.hcl
│     ├─ main.tf
│     ├─ modules
│     │  └─ groundwork
│     │     ├─ main.tf
│     │     ├─ outputs.tf
│     │     ├─ start.sh
│     │     └─ variables.tf
│     ├─ outputs.tf
│     ├─ provider.tf
│     └─ variables.tf
├─ .gitignore
├─ LICENSE
└─ README.md

```

## 🚀 Features - More to come

- Infrastructure as Code with **Terraform**
- Web Server custom image creation with **Packer**
- Package management with **Ansible**  
- **GCP** VM instances running sample web servers
- HTTP Load Balancer to distribute traffic across instances

## ✅ Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- A free-tier GCP project
- A service account with sufficient IAM permissions (Compute Admin, Network Admin)
- A GCP Bucket to store the Terraform state
- GCloud configured 
- GCP credentials exported as an environment variable:

  ```bash
  
  # ENV VARIABLE for Terraform - GCP usage
  #
  export TF_VAR_credentials_file="/path/to/your/credentials.json"
  export TF_VAR_project_id="your_project_id"
  
  # Packer GCP Variables
  #
  export PKR_VAR_project_id=$TF_VAR_project_id
  
  # Ansible GCP Variables
  #
  export GCP_AUTH_KIND="serviceaccount"
  export GCP_SERVICE_ACCOUNT_EMAIL="your_gcp_email"
  export GCP_SERVICE_ACCOUNT_FILE=$TF_VAR_credentials_file

  ```

## ⚙️ Getting Started

1. **Clone this repository:**

   ```bash
   git clone https://github.com/guilhermelinsc/devops.git
   cd devops/gcp/packer
   ```

2. **Initialize and Run Packer:**

   ```bash
   packer init .
   packer build .
   ```

3. **Initialize Terraform:**

   ```bash
   terraform init
   ```

4. **Review the execution plan:**

   ```bash
   terraform plan
   ```

5. **Apply the infrastructure:**

   ```bash
   terraform apply
   ```

   Type `yes` when prompted to confirm. Or use flag `-auto--approve`.

6. **Access the Load Balancer:**

   After the apply is complete, Terraform will output the external IP address of the load balancer.
   
   Open it in a browser or run the command below to test load balancing across nodes.
   
    ```bash
    while true; do sleep 1 && curl http://LB_external_IP; done
    ```
    Use CTRL+C to break the while.
  
## 🧼 Cleanup

   To destroy all the resources created:

   ```bash
   terraform destroy -auto-approve
   ```

## 🤝 Contributing

   Pull requests and suggestions are welcome! If you'd like to contribute, fork the repo and submit a PR.

## 📄 License

   This project is licensed under the [MIT License](LICENSE).
