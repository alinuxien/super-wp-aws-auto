resource "null_resource" "plays" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory ../ansible/install-apache.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory ../ansible/install-wordpress.yml"
  }

  depends_on = [
    aws_nat_gateway.ngw,
    aws_db_instance.database,
    aws_instance.webserver1,
    aws_instance.webserver2
  ]
}

