# 1.Target Group
# Target group for external services (30090)
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

# Target group for Argo CD (30080)
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

# Target group for Monitoring (30081)
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

# Target group for Kubernetes ALB (6443)
resource "aws_lb_target_group" "kube_alb_tg" {
  name        = "${var.naming}-alb-tg"
  port        = 6443
  protocol    = "HTTPS"
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

# 2. Load Balancer
# Public ALB
resource "aws_lb" "srv_alb" {
  name               = "${var.naming}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.albSGIds]
  subnets            = var.pubSubIds
}

# Private ALB
resource "aws_lb" "kube_alb" {
  name                             = "${var.naming}-kube-alb"
  internal                         = true
  load_balancer_type               = "application"
  subnets                          = [var.pvtAppSubCIds, var.pvtAppSubAIds]
  idle_timeout                     = 400
  enable_cross_zone_load_balancing = true
  security_groups            = [aws_security_group.alb_sg.id]
}

# ACM Certificate
resource "aws_acm_certificate" "kube_api_cert" {
  domain_name       = "api.gymfit.site"
  validation_method = "DNS"

  lifecycle {
    ignore_changes = [tags]
  }

  tags = {
    Name = "kube-api-cert"
  }
}

data "aws_acm_certificate" "kube_api_cert_data" {
  domain = aws_acm_certificate.kube_api_cert.domain_name
}

# 3.Listener
# Public ALB Listener for ArgoCD
resource "aws_lb_listener" "argocd_listener" {
  load_balancer_arn = aws_lb.srv_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.kube_api_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd_tg.arn 
  }
}

# Public ALB Listener for Monitoring
resource "aws_lb_listener" "monitoring_alb_nodeport" {
  load_balancer_arn = aws_lb.srv_alb.arn
  port              = 82
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monitoring_tg.arn
  }
}

# Private ALB Listener for Kubernetes API
resource "aws_lb_listener" "kube_api" {
  load_balancer_arn = aws_lb.kube_alb.arn
  port              = "6443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.kube_api_cert_data.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kube_alb_tg.arn
  }
}

# 4. Key Pair Definition
resource "aws_key_pair" "terraform_key_pair" {
  key_name   = var.keyName
  public_key = file("./.ssh/${var.keyName}.pub")

  tags = {
    description = "terraform key pair import"
  }
}

# 5.Instance
# Bastion Host
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

# Kubernetes Controller
resource "aws_instance" "kube_controller" {
  count         = var.kubeCtlCount
  ami           = var.kubeCtlAmi
  instance_type = var.kubeCtlType
  subnet_id     = count.index % 2 == 0 ? var.pvtAppSubAIds : var.pvtAppSubCIds
  key_name      = var.keyName

  vpc_security_group_ids = [var.kubeControllerSGIds, var.albSGIds]

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

# Attach Kubernetes Controller to Private ALB
resource "aws_lb_target_group_attachment" "tg-attach_controller" {
  count            = var.kubeCtlCount
  target_group_arn = aws_lb_target_group.kube_alb_tg.arn
  target_id        = element(aws_instance.kube_controller.*.private_ip, count.index)
}

# Kubernetes Worker
resource "aws_instance" "kube_worker" {
  count               = var.kubeNodCount
  ami                 = var.kubeNodAmi
  instance_type       = var.kubeNodType
  subnet_id           = count.index % 2 == 0 ? var.pvtAppSubAIds : var.pvtAppSubCIds
  key_name            = var.keyName
  vpc_security_group_ids = [var.kubeControllerSGIds, var.albSGIds]

  root_block_device {
    volume_size = var.kubeNodVolume
  }


  # Register worker to Public ALB (ArgoCD)
  provisioner "local-exec" {
    command = "aws elbv2 register-targets --target-group-arn ${aws_lb_target_group.argocd_tg.arn} --targets Id=${self.id}"
  }

  # Register worker to Public ALB (Monitoring)
  provisioner "local-exec" {
    command = "aws elbv2 register-targets --target-group-arn ${aws_lb_target_group.monitoring_tg.arn} --targets Id=${self.id}"
  }

  # Register worker to Public ALB (Service)
  provisioner "local-exec" {
    command = "aws elbv2 register-targets --target-group-arn ${aws_lb_target_group.service_tg.arn} --targets Id=${self.id}"
  }

  tags = {
    Name = "${var.naming}-kube-worker${count.index + 1}"
    role = "${var.naming}-kubecluster"
    feat = "${var.naming}-worker"
  }
}

# 6.Database
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