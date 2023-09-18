variable "beanstalkrole_name" {
  description = "gorole"
  type        = string
}

variable "myelasticapp" {
  default = "appgo2"
}

variable "beanstalkappenv" {
  default = "envgiteaapp"
}

variable "solution_stack_name" {
  default = "64bit Amazon Linux 2 v3.8.0 running Go 1"
}
variable "tier" {
  default = "WebServer"
}
