variable "org" {
  description = "Organization code to inlcude in resource names"
  type = string
}
variable "proj" {
  description = "Project code to include in resource names"
  type = string
}
variable "env" {
  description = "Environment code to include in resource names"
  type = string
}
variable "alb" {
  type = object({
    name = string
    subnet_id = list(string)
    security_group_id = list(string)
    default_tg = string
  })
}
variable "target_groups" {
  type = map(object({
    vpc_id = string
    type = optional(string,"instance")
    protocol = string
    port = number
    target_id = optional(list(string),[])
  }))
}
variable "rules" {
    type = map(object({
        priority = number
      condition = object({
        host_header = optional(list(string),[])
        path_pattern = optional(list(string),[])
        http_method = optional(list(string),[])
        source_ip = optional(list(string),[])
      })
      action = object({
        action_type = string
        target_group = optional(string,null)
        redirect = optional(object({
          host = optional(string)
          path = optional(string)
          port = optional(number)
          protocol = optional(string)
          status_code = string
        }))
      })
    }))
    default = {}
}
