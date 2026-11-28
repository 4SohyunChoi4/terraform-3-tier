terraform {
    required_version = ">= 1.10"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
            }
        random = {
            source = "hashicorp/random"
            version = "~> 3.6"
            }
        }
    backend "s3" {
        bucket = "sohyun-tf-state-1234"
        key = "d6-env/prod/terraform.tfstate"
        region = "ap-northeast-2"
        use_lockfile = true
        encrypt = true
        }
    }

provider "aws" {
    region = var.region

    default_tags {
        tags = {
            Project = var.project
            Environment = var.env
            ManagedBy = "terraform"
            }
    }
}

module "network" {
    source = "../../modules/network"
    project = var.project
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    }

module "compute" {
  source             = "../../modules/compute"
  project            = var.project
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  instance_type      = var.instance_type
  asg_desired        = var.asg_desired
}

module "database" {
  source                  = "../../modules/database"
  project                 = var.project
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  app_sg_id               = module.compute.app_sg_id
  db_instance_class       = var.db_instance_class
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
}