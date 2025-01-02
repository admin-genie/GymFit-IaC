# Security Group
resource "aws_security_group" "bastion_sg" {
  name   = "${var.naming}_bastion_sg"
  vpc_id = var.defVpcId

  # dynamic "ingress" {
  #   for_each = [for s in var.bastion_ingress_rules : {
  #     from_port = s.from_port
  #     to_port   = s.to_port
  #     desc      = s.desc
  #     cidr_blocks     = [s.cidr_blocks]
  #   }]
  #   content {
  #     from_port   = ingress.value.from_port
  #     to_port     = ingress.value.to_port
  #     cidr_blocks = ingress.value.cidr_blocks
  #     protocol    = "tcp"
  #     description = ingress.value.desc
  #   }
  # }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIp]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.naming}_bastion_sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.naming}_alb_sg"
  vpc_id = var.defVpcId

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.naming}_alb_sg"
  }
}
resource "aws_security_group" "kube_controller_sg" {
  name   = "${var.naming}_kube_controller_sg"
  vpc_id = var.defVpcId

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  dynamic "ingress" {
    for_each = [for s in var.kube_controller_ingress_rules : {
      from_port   = s.from_port
      to_port     = s.to_port
      desc        = s.desc
      cidr_blocks = [s.cidr_blocks]
    }]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = [var.cidrBlock]
      protocol    = "tcp"
      description = ingress.value.desc
    }
  }

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
    description = "Self Refer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.naming}_kube_controller_sg"
  }
}

resource "aws_security_group" "kube_worker_sg" {
  name   = "${var.naming}_kube_worker_sg"
  vpc_id = var.defVpcId

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    from_port       = 30443
    to_port         = 30443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  dynamic "ingress" {
    for_each = [for s in var.kube_worker_ingress_rules : {
      from_port   = s.from_port
      to_port     = s.to_port
      desc        = s.desc
      cidr_blocks = [s.cidr_blocks]
    }]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = [var.cidrBlock]
      protocol    = "tcp"
      description = ingress.value.desc
    }
  }

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
    description = "Self Refer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.naming}_kube_worker_sg"
  }
}

resource "aws_security_group" "db_mysql_sg" {
  name        = "${var.naming}-mysql-sg"
  description = "Security group for MySQL instances"

  vpc_id = var.defVpcId

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.kube_worker_sg.id]
  }  

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
    description = "Self Refer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.naming}-db-mysql-sg"
  }
}
