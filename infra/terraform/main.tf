# main.tf - The central orchestration file for our infrastructure.

# Configure the AWS provider, setting the region for all resources.
provider "aws" {
  region = var.aws_region
}

# --- VPC Module ---
# Provision the network foundation. This module creates a VPC, public/private subnets,
# an internet gateway, NAT gateways for outbound traffic from private subnets,
# and crucial VPC Endpoints to save on data transfer costs.
module "vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
  vpc_cidr   = "10.0.0.0/16"
}

# --- RDS Module (PostgreSQL Database) ---
# Provision a high-performance, fault-tolerant database.
# It lives in the private subnets and is only accessible from within our VPC.
module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.vpc_id
  db_subnet_ids         = module.vpc.private_subnet_ids
  db_password           = var.db_master_password
  # Allow traffic from the EKS cluster to the database.
  source_security_group_id = module.eks.cluster_security_group_id
}

# --- EKS Module (Kubernetes Cluster) ---
# Provision our main compute platform using Spot Instances for massive cost savings.
# This is where our application, monitoring, and other tools will run.
module "eks" {
  source             = "./modules/eks"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  cluster_name       = "devops-fleet-cluster"
}

# --- Jenkins Controller EC2 Module ---
# Provision a dedicated EC2 instance for our Jenkins master.
# We give it a dedicated instance to isolate our CI/CD workload.
module "jenkins_server" {
  source             = "./modules/jenkins-ec2"
  subnet_id          = module.vpc.public_subnet_ids[0] # Place Jenkins in a public subnet for easy access
  vpc_id             = module.vpc.vpc_id
  key_name           = "jenkins-key" # Assumes you have an SSH key pair named 'jenkins-key' in AWS
}