
variable "aws_region" {
  description = "AWS region for the EKS cluster"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "devops-dashboard-eks"
}

variable "vpc_id" {
  description = "Existing default VPC ID"
  type        = string
  default     = "vpc-0d916e778222c0d04"
}

variable "subnet_ids" {
  description = "Subnets in the existing default VPC"
  type        = list(string)

  default = [
    "subnet-0551730d923326195",
    "subnet-0d202c8f5afad673a",
    "subnet-011b19edc285ba83b",
    "subnet-004583e0c4067d855"
  ]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version; confirm it is supported in us-west-2"
  type        = string
  default     = "1.33"
}