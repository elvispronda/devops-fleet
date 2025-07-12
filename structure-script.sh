#!/bin/bash

# Set project root directory
PROJECT_NAME="my_fleet-web_app"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

echo "Creating professional project structure..."

# --- Backend ---
mkdir -p backend/app/{models,routes,schemas,services,utils}
mkdir -p backend/tests
touch backend/app/__init__.py
touch backend/app/{main.py,config.py}
touch backend/requirements.txt
touch backend/Dockerfile
touch backend/.env

# --- Frontend ---
mkdir -p frontend/public
mkdir -p frontend/src/{styles,scripts}
touch frontend/src/index.html
touch frontend/Dockerfile
touch frontend/.env

# --- Docker ---
mkdir -p docker/traefik
touch docker/docker-compose.yml
touch docker/{backend.Dockerfile,frontend.Dockerfile}
touch docker/traefik/{traefik.yml,dynamic_conf.yml}

# --- Kubernetes ---
mkdir -p k8s/{ingress,namespaces,deployments,services,secrets}
touch k8s/ingress/{ingress-backend.yaml,ingress-frontend.yaml,ingress-monitoring.yaml}

# --- Infrastructure ---
mkdir -p infra/terraform
mkdir -p infra/ansible/{inventory,playbooks}
mkdir -p infra/secrets/group_vars
touch infra/terraform/{main.tf,variables.tf,outputs.tf,cert_manager.tf}
touch infra/ansible/playbooks/{setup_jenkins.yml,setup_sonar.yml,setup_monitoring.yml,deploy_app.yml}

# --- CI/CD ---
mkdir -p ci-cd/pipelines
mkdir -p ci-cd/trivy
touch ci-cd/Jenkinsfile
touch ci-cd/pipelines/{backend.groovy,frontend.groovy,security_scan.groovy}
touch ci-cd/sonar-project.properties
touch ci-cd/trivy/trivy-policy.yaml

# --- Monitoring ---
mkdir -p monitoring/{prometheus,grafana/dashboards,loki}
touch monitoring/prometheus/{prometheus.yml,alert.rules.yml}
touch monitoring/grafana/datasources.yml
touch monitoring/loki/config.yml

# --- Notifications ---
mkdir -p notifications/email_sender
mkdir -p notifications/templates
touch notifications/templates/alert_email.html

# --- Scripts ---
mkdir -p scripts
touch scripts/{setup.sh,deploy.sh,certbot.sh,check_health.sh}

# --- Optional: GitHub Actions ---
mkdir -p .github/workflows
touch .github/workflows/ci.yml

# --- Misc ---
touch .env.example
touch .gitignore
touch README.md

echo "✅ Project structure created successfully!"

