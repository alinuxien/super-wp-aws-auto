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

output rds_address {
  value = aws_db_instance.database.address
}

output memcached_address {
  value = aws_elasticache_cluster.mllec.cluster_address
}

output memcached_configuration_endpoint {
  value = aws_elasticache_cluster.mllec.configuration_endpoint
}
