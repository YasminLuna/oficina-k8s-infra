provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "oficina-${var.environment}"
  cidr = "10.42.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = ["10.42.1.0/24", "10.42.2.0/24"]
  public_subnets  = ["10.42.101.0/24", "10.42.102.0/24"]

  # Ambiente academico: evita NAT Gateway para reduzir custo e permissoes.
  enable_nat_gateway       = false
  map_public_ip_on_launch  = true
  enable_dns_hostnames     = true
  enable_dns_support       = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.cluster_name}-${var.environment}"
  cluster_version = "1.35"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  # Ambiente academico: nodes em subnets publicas, sem NAT Gateway.
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Evita dependencias KMS/CloudWatch que nao sao obrigatorias para o desafio.
  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []
  create_kms_key              = false
  cluster_encryption_config   = {}

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}
