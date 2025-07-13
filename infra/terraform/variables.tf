variable "aws_region" {
  description = "The AWS region where all resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "db_master_password" {
  description = "The master password for the RDS database. Should be passed securely."
  type        = string
  sensitive   = true # Prevents Terraform from showing this value in logs.
}