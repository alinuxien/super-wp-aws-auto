resource "null_resource" "plays_logstash" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory ../ansible/install-logstash.yml"
  }

  depends_on = [
    aws_elasticsearch_domain.es
  ]
}

