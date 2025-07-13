# modules/eks/main.tf - Defines our Kubernetes cluster.

# ... (EKS Cluster Role and other IAM setup) ...

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  # ...
}

# --- EKS Node Group with SPOT INSTANCES ---
# This is our primary cost-saving strategy for compute.
# We instruct AWS to run our application on spare EC2 capacity, which can be up to 90% cheaper.
# EKS is designed to handle Spot Instance terminations gracefully by rescheduling pods elsewhere.
resource "aws_eks_node_group" "spot_workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "spot-application-workers"
  
  # CRITICAL: Use Spot capacity instead of On-Demand.
  capacity_type  = "SPOT"

  # Provide multiple instance types. If one type is unavailable as a Spot instance,
  # the autoscaler will try the next one, increasing resilience.
  instance_types = ["t3.large", "t3a.large", "m5.large", "m5a.large"]
  
  scaling_config {
    # This config allows the Cluster Autoscaler to dynamically resize the infrastructure.
    desired_size = 2  # Start with 2 nodes.
    max_size     = 15 # Allow scaling up to 15 nodes under heavy load.
    min_size     = 1  # IMPORTANT: Scale down to a single node during low-peak times.
  }

  # These tags are required for the Cluster Autoscaler to discover and manage this node group.
  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
  # ...
}