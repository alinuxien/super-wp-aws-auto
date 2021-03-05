resource "null_resource" "plays_beats" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory ../ansible/install-metricbeat.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory ../ansible/install-filebeat.yml"
  }

  depends_on = [
    aws_elasticsearch_domain.es,
    null_resource.plays_logstash
  ]
}

