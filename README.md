# Terraform Code for Web Server with Load Balancer

This project aims to automate the deployment of a WebServer using **Terraform, Packer, and Ansible.**

Currently, this project provisions the infrastructure on **Google Cloud Platform (GCP)** using **Terraform**, to deploy a scalable web server environment behind a **load balancer**. 
Each web server node serves a sample page that displays its own hostname, demonstrating which instance handled the request and the load balancing in action.

## 📁 Project Structure

```bash
devops/ 
└── gcp/ 
  └── terraform/ 
    ├── main.tf 
    ├── variables.tf 
    └── outputs.tf 
      └── modules/ 
        └── groundwork/ 
          ├── main.tf
          ├── variables.tf 
          └── outputs.tf 
```

## 🚀 Features - More to come

- Infrastructure as Code with Terraform
- GCP VM instances running sample web servers
- HTTP Load Balancer to distribute traffic across instances

## ✅ Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- A free-tier GCP project
- A service account with sufficient IAM permissions (Compute Admin, Network Admin)
- GCloud configured 
- GCP credentials exported as an environment variable:

  ```bash
  export TF_VAR_credentials_file="/path/to/your/credentials.json"
  ```

## ⚙️ Getting Started

1. **Clone this repository:**

   ```bash
   git clone https://github.com/guilhermelinsc/devops.git
   cd devops/gcp/terraform
   ```

2. **Initialize Terraform:**

   ```bash
   terraform init
   ```

3. **Review the execution plan:**

   ```bash
   terraform plan
   ```

4. **Apply the infrastructure:**

   ```bash
   terraform apply
   ```

   Type `yes` when prompted to confirm.

5. **Access the Load Balancer:**

   After the apply is complete, Terraform will output the external IP address of the load balancer.
   
   Open it in a browser or run the command below to test load balancing across nodes.
   
    ```bash
    while true; do sleep 3 && curl http://LB_external_IP; done
    ```
    Use CTRL+C to break the while.
  
## 🧼 Cleanup

To destroy all the resources created:

```bash
terraform destroy
```

## 🤝 Contributing

Pull requests and suggestions are welcome! If you'd like to contribute, fork the repo and submit a PR.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
