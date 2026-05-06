terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "coalfire-terraform-state-510674264237"
    key            = "coalfire/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "coalfire-assessment"
      ManagedBy   = "Terraform"
    }
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  vpc_cidr                  = var.vpc_cidr
  application_subnet_cidrs  = var.application_subnet_cidrs
  management_subnet_cidr    = var.management_subnet_cidr
  backend_subnet_cidrs      = var.backend_subnet_cidrs
  environment               = var.environment
  common_tags               = local.common_tags
}

# Security Groups Module
module "security" {
  source = "../../modules/security"

  vpc_id                   = module.networking.vpc_id
  environment              = var.environment
  management_access_cidrs  = var.management_access_cidrs
  common_tags              = local.common_tags
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  vpc_id                   = module.networking.vpc_id
  application_subnet_ids   = module.networking.application_subnet_ids
  alb_security_group_id    = module.security.alb_sg_id
  environment              = var.environment
  target_port             = 80
  common_tags              = local.common_tags
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  environment                    = var.environment
  instance_type                  = var.instance_type
  asg_min_size                   = var.asg_min_size
  asg_max_size                   = var.asg_max_size
  asg_desired_capacity           = var.asg_desired_capacity
  application_subnet_ids         = module.networking.application_subnet_ids
  management_subnet_id           = module.networking.management_subnet_id
  app_security_group_id          = module.security.app_asg_sg_id
  management_security_group_id   = module.security.management_sg_id
  target_group_arn               = module.alb.target_group_arn
  common_tags                    = local.common_tags
  key_name                       = var.key_name
}
