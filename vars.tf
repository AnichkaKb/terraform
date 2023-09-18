variable "region" {
    type= string
    default = "us-east-1"
}
variable "vpc_cidr_block" {
    type= string
    default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
    type = string
    default = "10.0.0.0/24"
}
