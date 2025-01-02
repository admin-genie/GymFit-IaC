
cidrBlock = {
    default = "10.0.0.0/16"
}

# Security Groups setting

# bastion_ingress_rules = [
#   {
#     from_port = "3389",
#     to_port   = "3389",
#     cidr      = var.myIp/32
#     desc      = "RDP from dev"
#   }
# ]

kube_controller_ingress_rules = [
  {
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for jenkins"
  },

  {
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for kube API server"
  },

  {
    from_port   = 2379
    to_port     = 2380
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for etcd and kube-apiserver"
  },

  {
    from_port   = 179
    to_port     = 179
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for calico netwoking plugin"
  },

  {
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for kubelet API"
  },

  {
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["var.cidrBlock"]
    desc = "nodeport allowd"
  }
]
kube_worker_ingress_rules = [
  {
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for kubelet API"
  },

  {
    from_port   = 179
    to_port     = 179
    cidr_blocks = ["var.cidrBlock"]
    desc = "allowed for calico netwoking plugin"
  },

  {
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["var.cidrBlock"]
    desc = "nodeport allowd"
  },

  {
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["var.cidrBlock"]
    desc = "ssh for manager group"
  }
]