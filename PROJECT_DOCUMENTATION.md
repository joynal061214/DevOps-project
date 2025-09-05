# Deel Test App Documentation

## Overview

Deel Test App is a Python Flask application containerized with Docker and provisioned for cloud deployment using Terraform. It is designed for easy local development, containerization, and infrastructure-as-code deployment.

---

## Project Structure

```
deel-test-app/
│
├── app.py                # Main Flask application
├── Dockerfile            # Docker build instructions
├── requirements.txt      # Python dependencies
├── README.md             # Project documentation
├── setup-aws.md          # AWS setup instructions
└── terraform/            # Infrastructure as code
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

---

## Prerequisites

- Python 3.13+
- Docker Desktop
- Terraform CLI
- AWS account (for cloud deployment)

---

## Local Development

1. **Install Python dependencies:**
   ```bash
   python -m pip install -r requirements.txt
   ```

2. **Run the Flask app:**
   ```bash
   python app.py
   ```
   The app will be available at `http://localhost:8080`.

---

## Docker Usage

1. **Build the Docker image:**
   ```bash
   docker build -t deel-test-app .
   ```

2. **Run the container:**
   ```bash
   docker run -d -p 8080:8080 deel-test-app
   ```
   Access the app at `http://localhost:8080`.

---

## Terraform Infrastructure

1. **Configure AWS credentials:**
   - Use `aws configure` or set environment variables as described in `setup-aws.md`.

2. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init
   ```

3. **Validate configuration:**
   ```bash
   terraform validate
   ```

4. **Apply infrastructure:**
   ```bash
   terraform apply -auto-approve
   ```

---

## Files Description

- **app.py**: Flask web server with API endpoints.
- **Dockerfile**: Builds a minimal Python container for the app.
- **requirements.txt**: Lists required Python packages (e.g., Flask).
- **setup-aws.md**: Instructions for setting up AWS credentials.
- **terraform/main.tf**: Main Terraform configuration (resources, providers).
- **terraform/variables.tf**: Input variables for Terraform.
- **terraform/outputs.tf**: Output values from Terraform deployment.

---

## Troubleshooting

- **Docker not found**: Ensure Docker Desktop is installed and running.
- **Terraform errors**: Make sure you have valid AWS credentials and run `terraform init` before `terraform apply`.
- **Flask errors**: Check that all dependencies in `requirements.txt` are installed.

---

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Open a pull request.

---

## License

Specify your license here (e.g., MIT, Apache 2.0).

---
