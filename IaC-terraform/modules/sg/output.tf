output "kube_controller_sg_id" {
  value = aws_security_group.kube_controller_sg.id
}

output "kube_worker_sg_id" {
  value = aws_security_group.kube_worker_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "db_mysql_sg_id" {
  value = aws_security_group.db_mysql_sg.id
}
