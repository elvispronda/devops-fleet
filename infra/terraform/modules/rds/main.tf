# modules/rds/main.tf - Defines our managed PostgreSQL database.

# ... (DB Subnet Group, Security Group allowing access from EKS) ...

# --- Master DB Instance (for WRITE operations) ---
# We use a Graviton (g) instance type for better price/performance.
resource "aws_db_instance" "master" {
  identifier           = "fleet-master-db"
  engine               = "postgres"
  instance_class       = "db.m6g.large" # General purpose Graviton instance
  multi_az             = true # For high availability, creates a standby in another AZ.
  # ... (storage, username, password from var.db_password, etc.) ...
}

# --- Read Replica Instance (for READ operations) ---
# This is a key performance optimization. All read-heavy operations (dashboards, reports)
# will hit this replica, offloading the master instance to focus solely on fast writes.
resource "aws_db_instance" "replica" {
  identifier           = "fleet-read-replica"
  instance_class       = "db.r6g.large" # Memory-optimized Graviton instance, ideal for reads.
  
  # This links the replica to the master.
  replicate_source_db  = aws_db_instance.master.id
}