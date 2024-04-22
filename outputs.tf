
output "tg_arn" {
  value = { for k,v in var.target_groups: k => aws_lb_target_group.public_alb[k].arn}
}
