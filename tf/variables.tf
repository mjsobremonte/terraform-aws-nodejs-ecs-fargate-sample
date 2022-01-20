variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "ca-central-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
}

variable "prefix" {
  description = "Prefix all resources created"
  default     = "terraform-sample"
}

variable "ecs_environment" {
  default = "test"
}

variable "ecs_container_port" {
  default = "8080"
}

variable "ecs_host_port" {
  default = "8080"
}

variable "ecs_ingress_from_port" {
  default = 8080
}

variable "ecs_ingress_to_port" {
  default = 8080
}

variable "lb_ingress_from_port" {
  default = 80
}

variable "lb_ingress_to_port" {
  default = 80
}
