# TargetGroup
resource "aws_lb_target_group" "service_tg" {
  name     = "${var.naming}-service-tg"
  port     = 30090
  protocol = "HTTP"
  vpc_id   = var.defVpcId

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "argocd_tg" {
  name     = "${var.naming}-argocd-tg"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = var.defVpcId

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "monitoring_tg" {
  name     = "${var.naming}-monitoring-tg"
  port     = 30081
  protocol = "HTTP"

  vpc_id = var.defVpcId

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "kube_nlb_tg" {
  name        = "${var.naming}-nlb-tg"
  port        = 6443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.defVpcId

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTPS"
    path                = "/healthz"
  }
}

# LoadBalancer
resource "aws_lb" "srv_alb" {
  name               = "${var.naming}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.albSGIds]
  subnets            = var.pubSubIds
}

resource "aws_lb" "kube_nlb" {
  name                             = "${var.naming}-kube-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = [var.pvtAppSubCIds, var.pvtAppSubAIds]
  idle_timeout                     = 400
  enable_cross_zone_load_balancing = true
}

# LB Listener
resource "aws_lb_listener" "srv_alb_http" {
  load_balancer_arn = aws_lb.srv_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg.arn
  }
}

resource "aws_lb_listener" "argocd_alb_nodeport" {
  load_balancer_arn = aws_lb.srv_alb.arn
  port              = 81
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd_tg.arn
  }
}

resource "aws_lb_listener" "monitoring_alb_nodeport" {
  load_balancer_arn = aws_lb.srv_alb.arn
  port              = 82
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monitoring_tg.arn
  }
}

resource "aws_lb_listener" "kube_api" {
  load_balancer_arn = aws_lb.kube_nlb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_nlb_tg.arn
  }
}

# aws_key_pair resource 설정
resource "aws_key_pair" "terraform_key_pair" {
  # 등록할 key pair의 name
  key_name = var.keyName

  # public_key = "{.pub 파일 내용}"
  public_key = file("./.ssh/${var.keyName}.pub")

  tags = {
    description = "terraform key pair import"
  }
}

# Instance
resource "aws_instance" "bastion_host" {
  count           = length(var.pubSubIds)
  ami             = var.bastionAmi
  instance_type   = "t3.micro"
  subnet_id       = var.pubSubIds[count.index]
  key_name        = var.keyName
  security_groups = [var.bastionSGIds]

  associate_public_ip_address = true

  user_data = file("${path.module}/user_data/user_data_bastion_host.sh")

  tags = {
    Name = "${var.naming}_bastion_host${count.index + 1}"
  }
}


resource "aws_instance" "kube_controller" {
  count         = var.kubeCtlCount
  ami           = var.kubeCtlAmi
  instance_type = var.kubeCtlType
  subnet_id     = count.index % 2 == 0 ? var.pvtAppSubAIds : var.pvtAppSubCIds
  key_name      = var.keyName

  vpc_security_group_ids = [var.kubeControllerSGIds]

  root_block_device {
    volume_size = var.kubeCtlVolume
  }

  user_data = file("${path.module}/user_data/user_data_kubecontroller.sh")

  tags = {
    Name = "${var.naming}-kube-controller${count.index + 1}"
    role = "${var.naming}-kubecluster"
    feat = "${var.naming}-controller"
  }
}

resource "aws_lb_target_group_attachment" "tg-attach_controller" {
  count            = var.kubeCtlCount
  target_group_arn = aws_lb_target_group.kube_nlb_tg.arn
  target_id        = element(aws_instance.kube_controller.*.private_ip, count.index)
}

resource "aws_instance" "kube_worker" {
  count         = var.kubeNodCount
  ami           = var.kubeNodAmi
  instance_type = var.kubeNodType
  subnet_id     = count.index % 2 == 0 ? var.pvtAppSubAIds : var.pvtAppSubCIds
  key_name      = var.keyName

  vpc_security_group_ids = [var.kubeWorkerSGIds]

  root_block_device {
    volume_size = var.kubeNodVolume
  }

  provisioner "local-exec" {
    command = "aws elbv2 register-targets --target-group-arn ${aws_lb_target_group.argocd_tg.arn} --targets Id=${self.id}"
  }

  provisioner "local-exec" {
    command = "aws elbv2 register-targets --target-group-arn ${aws_lb_target_group.monitoring_tg.arn} --targets Id=${self.id}"
  }

  provisioner "local-exec" {
    command = "aws elbv2 register-targets --target-group-arn ${aws_lb_target_group.service_tg.arn} --targets Id=${self.id}"
  }

  tags = {
    Name = "${var.naming}-kube-worker${count.index + 1}"
    role = "${var.naming}-kubecluster"
    feat = "${var.naming}-worker"
  }
}

resource "aws_instance" "db" {
  count           = length(var.pubSubIds)
  ami             = var.kubeNodAmi
  instance_type   = var.kubeNodType
  key_name        = var.keyName
  subnet_id       = count.index % 2 == 0 ? var.pvtDBSubCIds : var.pvtDBSubCIds
  security_groups = [var.dbMysqlSGIds]

  root_block_device {
    volume_size = var.kubeNodVolume
  }

  user_data = file("${path.module}/user_data/user_data_db_mysql.sh")


  tags = {
    Name = "${var.naming}-db-${count.index % 2 == 0 ? "Primary" : "Secondary"}"
  }
}
