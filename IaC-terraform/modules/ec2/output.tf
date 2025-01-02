output "srv_alb_name" {
  value = aws_lb.srv_alb.name
}


output "bastion_public_ips" {
  value = aws_instance.bastion_host[*].public_ip
}

output "kube_controller_ips" {
  value = aws_instance.kube_controller[*].private_ip
}

output "kube_worker_ips" {
  value = aws_instance.kube_worker[*].private_ip
}

output "db_ips" {
  value = aws_instance.db[*].private_ip
}

output "kube_nlb_dns" {
  value = aws_lb.kube_nlb.dns_name
}
