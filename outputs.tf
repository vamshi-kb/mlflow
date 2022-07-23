output "alb_hostname" {
  value = aws_alb.main.dns_name
}

output "load_balancer_arn" {
  value = aws_alb.main.arn
}

output "load_balancer_target_group_id" {
  value = aws_alb_target_group.app.id
}

output "load_balancer_zone_id" {
  value = aws_alb.main.zone_id
}

output "load_balancer_dns_name" {
  value = aws_alb.main.dns_name
}

output "cluster_id" {
  value = aws_ecs_cluster.main.name
}
