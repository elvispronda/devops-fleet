# modules/vpc/main.tf - Defines our core network.

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "devops-fleet-vpc" }
}

# ... (Code for public/private subnets, Internet Gateway, NAT Gateway) ...

# --- VPC Endpoints: A major cost-saving and security feature ---
# By creating these endpoints, traffic from our EKS/EC2 instances to these AWS services
# travels over the private AWS backbone, NOT the public internet.
# This means:
# 1. ZERO data transfer costs for pulling images from ECR or accessing S3.
# 2. Enhanced security as traffic doesn't leave the AWS network.

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  # ... (associate with private subnets and security groups) ...
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  # ... similar to ecr_api but for the ecr.dkr service ...
}