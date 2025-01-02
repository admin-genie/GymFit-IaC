# Terraform Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }
  backend "s3" {
    bucket = "gf-prd-tfstate-s3-04301704"
    key    = "terraform.tfstate"
    region = "sa-east-1"
    #    dynamodb_table = "terraform-lock" # s3 bucket을 이용한 협업을 위해 설정 
  }
}
resource "aws_s3_bucket" "tf_backend" {
  count  = terraform.workspace == "default" ? 1 : 0 # workspace가 default일 때만 실행해라
  bucket = "gf-prd-tfstate-s3-04301704"
  # versioning {                   # deprecated된 문법으로 사용이 가능하긴 하나 권장하지 않음, 자체모듈에서 삭제시 업데이트 필요
  #   enabled = true
  # }
  tags = {
    Name = "gf-prd-tfstate-s3-04301704"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" {
  count  = terraform.workspace == "default" ? 1 : 0 # workspace가 default일 때만 실행해라
  bucket = aws_s3_bucket.tf_backend[0].id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "tf_backend_ownership" {
  count  = terraform.workspace == "default" ? 1 : 0 # workspace가 default일 때만 실행해라
  bucket = aws_s3_bucket.tf_backend[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}  


# Configure AWS Provider
provider "aws" {
  region = "sa-east-1"
}

# VPC Count
module "main_vpc" {
  source     = "./modules/vpc"
  naming     = "gf-prd"
  cidrBlock = "10.10.0.0/16"
}
# sg module set
module "sg" {
  source    = "./modules/sg"
  naming    = "gf-prd"
  cidrBlock = "10.10.0.0/16"
  kube_controller_ingress_rules = var.kube_controller_ingress_rules
  kube_worker_ingress_rules     = var.kube_worker_ingress_rules
  defVpcId      = module.main_vpc.def_vpc_id
  myIp = "61.85.118.29/32"
}

# Instance
module "instance" {
  source        = "./modules/ec2"
  naming        = "gf-prd"
  myIp          = "61.85.118.29/32"
  defVpcId      = module.main_vpc.def_vpc_id
  cidrBlock     = "10.10.0.0/16"
  pubSubIds     = module.main_vpc.public_sub_ids
  pvtAppSubAIds = module.main_vpc.pri_app_sub_a_ids
  pvtAppSubCIds = module.main_vpc.pri_app_sub_c_ids
  pvtDBSubAIds  = module.main_vpc.pri_db_sub_a_ids
  pvtDBSubCIds  = module.main_vpc.pri_db_sub_c_ids
  kubeControllerSGIds = module.sg.kube_controller_sg_id
  kubeWorkerSGIds     = module.sg.kube_worker_sg_id
  albSGIds            = module.sg.alb_sg_id
  bastionSGIds        = module.sg.bastion_sg_id
  dbMysqlSGIds        = module.sg.db_mysql_sg_id
  bastionAmi    = "ami-084dc6d47813a2785"
  kubeCtlAmi    = "ami-084dc6d47813a2785"
  kubeCtlType   = "t3.medium"
  kubeCtlVolume = 20
  kubeCtlCount  = 3
  kubeNodAmi    = "ami-084dc6d47813a2785"
  kubeNodType   = "t3.medium"
  kubeNodVolume = 20
  kubeNodCount  = 3
  keyName       = "gf-prd-ec2"
}

