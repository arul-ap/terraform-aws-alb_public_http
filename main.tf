locals {
  name-prefix = lower("${var.org}-${var.proj}-${var.env}") // prefix for naming resources
}

data "aws_region" "current" {}

resource "aws_lb" "public" {
  name = "${local.name-prefix}-${var.alb.name}"
  internal = false
  subnets = var.alb.subnet_id
  security_groups = var.alb.security_group_id
}

resource "aws_lb_listener" "public" {
  load_balancer_arn = aws_lb.public.arn
  protocol = "HTTP"
  port = "80"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.public_alb[var.alb.default_tg].arn 
  }
}

resource "aws_lb_target_group" "public_alb" {
  for_each = var.target_groups
  name = "${local.name-prefix}-tg-${each.key}"
  target_type = each.value.type
  vpc_id = each.value.vpc_id
  protocol = each.value.protocol
  port = each.value.port
}

locals {
  tg_with_targets = {for k,v in var.target_groups: k => v if v.target_id != [] }
}

module "tg_attach" {
  for_each = local.tg_with_targets
  source = "./modules/tg_attach"
  tg_arn = aws_lb_target_group.public_alb[each.key].arn
  targets = each.value.target_id
}

locals {
  forward_rules = { for k,v in var.rules: k => v if v.action.action_type == "forward"}
  redirect_rules = { for k,v in var.rules: k => v if v.action.action_type == "redirect"}
}

module "redirect" {
  for_each = local.redirect_rules
  source = "./modules/redirect_rule"
  alb_listener_arn = aws_lb_listener.public.arn
  priority = each.value.priority
  condition = each.value.condition
  redirect = each.value.action.redirect
}

module "forward" {
  for_each = local.forward_rules
  source = "./modules/forward_rule"
  alb_listener_arn = aws_lb_listener.public.arn
  priority = each.value.priority
  condition = each.value.condition
  target_group_arn = aws_lb_target_group.public_alb[each.value.action.target_group].arn
}
