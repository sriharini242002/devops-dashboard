
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access = true

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      name           = "dashboard-workers"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }

  tags = {
    Project     = "devops-dashboard"
    Environment = "learning"
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.59.0"

  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa"
      ]
    }
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn

  depends_on = [module.eks]
}