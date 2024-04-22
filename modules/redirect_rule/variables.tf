variable "condition" {
  type = object({
    host_header = optional(list(string),[])
    path_pattern = optional(list(string),[])
    http_method = optional(list(string),[])
    source_ip = optional(list(string),[])
  })
}
variable "redirect" {
  type = object({
    host = optional(string)
    path = optional(string)
    port = optional(number)
    protocol = optional(string)
    status_code = string
  })
}

variable "alb_listener_arn" {
  type = string
}
variable "priority" {
  type = number
}
