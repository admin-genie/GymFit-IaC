# Terraform Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }

  # S3 Backend
  backend "s3" {
    bucket = "gf-prd-tfstate-s3-04301704"
    key    = "terraform.tfstate"
    region = "sa-east-1"
  }
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "tf_backend" {
  count = terraform.workspace == "default" ? 1 : 0 # Default workspace에서만 생성
  bucket = "gf-prd-tfstate-s3-04301704"

  tags = {
    Name = "gf-prd-tfstate-s3-04301704"
  }
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "tf_backend_acl" {
  count = terraform.workspace == "default" ? 1 : 0 # Default workspace에서만 생성
  bucket = aws_s3_bucket.tf_backend[0].id
  acl    = "private"
}

# S3 Bucket Ownership
resource "aws_s3_bucket_ownership_controls" "tf_backend_ownership" {
  count = terraform.workspace == "default" ? 1 : 0 # Default workspace에서만 생성
  bucket = aws_s3_bucket.tf_backend[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# AWS Provider
provider "aws" {
  region = "sa-east-1"
}

# VPC Module
module "main_vpc" {
  source    = "./modules/vpc"
  naming    = "gf-prd"
  cidrBlock = "10.10.0.0/16"
}

# Security Group Module
module "sg" {
  source                  = "./modules/sg"
  naming                  = "gf-prd"
  cidrBlock               = "10.10.0.0/16"
  kube_controller_ingress_rules = var.kube_controller_ingress_rules
  kube_worker_ingress_rules     = var.kube_worker_ingress_rules
  defVpcId                  = module.main_vpc.def_vpc_id
  myIp                     = "61.85.118.29/32"
}

# EC2 Instance Module
module "instance" {
  source               = "./modules/ec2"
  naming               = "gf-prd"
  myIp                 = "61.85.118.29/32"
  defVpcId             = module.main_vpc.def_vpc_id
  cidrBlock            = "10.10.0.0/16"
  pubSubIds            = module.main_vpc.public_sub_ids
  pvtAppSubAIds        = module.main_vpc.pri_app_sub_a_ids
  pvtAppSubCIds        = module.main_vpc.pri_app_sub_c_ids
  pvtDBSubAIds         = module.main_vpc.pri_db_sub_a_ids
  pvtDBSubCIds         = module.main_vpc.pri_db_sub_c_ids
  kubeControllerSGIds  = module.sg.kube_controller_sg_id
  kubeWorkerSGIds      = module.sg.kube_worker_sg_id
  albSGIds             = module.sg.alb_sg_id
  bastionSGIds         = module.sg.bastion_sg_id
  dbMysqlSGIds         = module.sg.db_mysql_sg_id
  bastionAmi           = "ami-084dc6d47813a2785"
  kubeCtlAmi           = "ami-084dc6d47813a2785"
  kubeCtlType          = "t3.medium"
  kubeCtlVolume        = 20
  kubeCtlCount         = 3
  kubeNodAmi           = "ami-084dc6d47813a2785"
  kubeNodType          = "t3.medium"
  kubeNodVolume        = 20
  kubeNodCount         = 3
  keyName              = "gf-prd-ec2"
}