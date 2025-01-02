variable "naming" {
  type    = string
  default = "def"
}

variable "cidrBlock" {
  type    = string
  default = "10.0.0.0/16"
}

variable "myIp" {
  type    = string
  default = "0.0.0.0/0"
}

variable "defVpcId" {
  type = string
}

variable "kube_controller_ingress_rules" {}

variable "kube_worker_ingress_rules" {}

# variable "bastion_ingress_rules" {}