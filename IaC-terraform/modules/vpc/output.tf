output "def_vpc_id" {
  value = aws_vpc.def_vpc.id
}

output "pri_app_sub_a_ids" {
  value = aws_subnet.pri_app_a.id
}

output "pri_app_sub_c_ids" {
  value = aws_subnet.pri_app_c.id
}

output "pri_db_sub_a_ids" {
  value = aws_subnet.pri_db_a.id
}

output "pri_db_sub_c_ids" {
  value = aws_subnet.pri_db_c.id
}

output "public_sub_ids" {
  value = [aws_subnet.pub_a.id, aws_subnet.pub_c.id]
}


