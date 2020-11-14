output bastion_ip {
  value = aws_instance.bastion.public_ip
}

output webserver1_ip {
  value = aws_instance.webserver1.private_ip
}

output webserver2_ip {
  value = aws_instance.webserver2.private_ip
}

output alb_dns_name {
  value = aws_lb.alb.dns_name
}

#output cloud_front_dns_name {
#  value = aws_cloudfront_distribution.cloudfront.domain_name
#}

output rds_address {
  value = aws_db_instance.database.address
}

output memcached_address {
  value = aws_elasticache_cluster.mllec.cluster_address
}

output memcached_configuration_endpoint {
  value = aws_elasticache_cluster.mllec.configuration_endpoint
}

resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl", {
    bastion-dns      = aws_instance.bastion.private_dns,
    bastion-ip       = aws_instance.bastion.public_ip,
    bastion-id       = aws_instance.bastion.id,
    bastion-user     = var.bastion-user,
    webserver1-dns   = aws_instance.webserver1.private_dns,
    webserver1-ip    = aws_instance.webserver1.private_ip,
    webserver1-id    = aws_instance.webserver1.id
    webserver2-dns   = aws_instance.webserver2.private_dns,
    webserver2-ip    = aws_instance.webserver2.private_ip,
    webserver2-id    = aws_instance.webserver2.id,
    webservers-user  = var.webservers-user,
    private_key_file = var.private_key_file
  })
  filename = "../ansible/inventory"
}

resource "local_file" "AnsibleWPCLIConfig" {
  content = templatefile("config.yml.tmpl", {
    db_server           = aws_db_instance.database.address,
    db_name             = var.database-name,
    db_user             = var.database-username,
    db_pass             = var.database-password,
    webserver_path      = var.webserver-homepage-path,
    final_url           = var.final_url,
    website_title       = var.website_title,
    website_admin       = var.website_admin,
    website_admin_pass  = var.website_admin_pass,
    website_admin_email = var.website_admin_email,
    memchached_server   = aws_elasticache_cluster.mllec.configuration_endpoint
  })
  filename = "../ansible/roles/wordpress-cli/tasks/config.yml"
}

